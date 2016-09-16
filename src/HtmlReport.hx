import coverme.*;

using StringTools;

class HtmlReport {
    public static function report(coverage:Coverage, outDir:String) {
        deleteRec(outDir);
        sys.FileSystem.createDirectory(outDir);
        for (f in ["github.css", "highlight.pack.js"])
            sys.io.File.copy(f, '$outDir/$f');

        function link(href:String, name:String) {
            return '<a href="$href">${name.htmlEscape()}</a>';
        }

        var index = [
            "<h1>Packages</h1>"
        ];

        index.push("<ul>");
        for (pack in coverage.packages) {
            var dotPath = pack.path.join(".");
            var packDir = if (dotPath == "") "root-package" else dotPath;
            sys.FileSystem.createDirectory('$outDir/$packDir');

            var packIndex = [
                '<h1>Package: ${if (dotPath == "") "<root package>".htmlEscape() else dotPath}</h1>',
                link("../index.html", "go up"),
            ];
            packIndex.push("<ul>");
            for (module in pack.modules) {
                sys.FileSystem.createDirectory('$outDir/$packDir/${module.name}');

                var moduleStr = pack.path.concat([module.name]).join(".");
                var moduleIndex = [
                    '<h1>Module: $moduleStr</h1>',
                    link("../index.html", "go up"),
                ];
                moduleIndex.push("<ul>");
                var firstType = null;
                for (type in module.types) {
                    if (firstType == null)
                        firstType = type.name;

                    var content = [
                        '<h1>Type: ${type.name} ($moduleStr)</h1>',
                        link("./index.html", "go up"),
                        renderTypePage(type),
                    ];

                    sys.io.File.saveContent('$outDir/$packDir/${module.name}/${type.name}.html', content.join("\n"));

                    moduleIndex.push('\t<li>' + link('${type.name}.html', type.name));
                }
                moduleIndex.push("</ul>");
                sys.io.File.saveContent('$outDir/$packDir/${module.name}/index.html', moduleIndex.join("\n"));

                if (firstType != null && module.types.length == 1) {
                    packIndex.push("\t<li>" + link('${module.name}/$firstType.html', module.name));
                } else {
                    packIndex.push("\t<li>" + link('${module.name}/index.html', module.name));
                }
            }
            packIndex.push("</ul>");
            sys.io.File.saveContent('$outDir/$packDir/index.html', packIndex.join("\n"));

            index.push("\t<li>" + link('$packDir/index.html', if (dotPath == "") "<root package>" else dotPath));
        }
        index.push("</ul>");

        sys.io.File.saveContent('$outDir/index.html', index.join("\n"));
    }

    static function deleteRec(dir:String) {
        if (!sys.FileSystem.exists(dir))
            return;
        for (file in sys.FileSystem.readDirectory(dir)) {
            var path = '$dir/$file';
            if (sys.FileSystem.isDirectory(path)) {
                deleteRec(path);
            } else {
                sys.FileSystem.deleteFile(path);
            }
        }
        sys.FileSystem.deleteDirectory(dir);
    }

    public static function renderTypePage(type:ModuleType):String {
        var files = new Map();
        function getFileData(file) {
            var data = files[file];
            if (data == null)
                data = files[file] = {branches: [], statements: [], fields: []};
            return data;
        }

        for (field in type.fields) {
            getFileData(field.pos.file).fields.push(field);
            for (branch in field.branches)
                getFileData(branch.pos.file).branches.push(branch);
            for (statement in field.statements)
                getFileData(statement.pos.file).statements.push(statement);
        }

        var output = ['<link rel="stylesheet" href="../../github.css">
<script src="../../highlight.pack.js"></script>
<script>hljs.initHighlightingOnLoad();</script>
<style>
.missing {
    background-color: #fc8c84;
}

.missing:hover, .covered:hover {
    background-color: #ffe87c;
    border-left: 1px solid gray;
    border-right: 1px solid gray;
}
</style>'];

        for (file in files.keys()) {
            output.push('<h2>source file: $file</h2>');
            var content = sys.io.File.getContent(file);
            var chars = [
                for (i in 0...content.length) {
                    var c = content.charAt(i);
                    c = StringTools.htmlEscape(c, true);
                    c;
                }
            ];
            var insertions = new Map<Int,Array<String>>();

            function insert(pos:Int, html:String) {
                var ins = insertions[pos];
                if (ins == null)
                    ins = insertions[pos] = [];
                ins.push(html);
            }

            var fileData = files[file];

            for (field in fileData.fields) {
                if (field.count == 0)
                    insert(field.pos.min, '<span class="missing" title="field not evaluated">');
                else
                    insert(field.pos.min, '<span class="covered" title="field evaluated ${field.count} times">');
                insert(field.pos.max, '</span>');
            }

            for (branch in fileData.branches) {
                var missing = [];
                if (branch.trueCount == 0)
                    missing.push("true");
                if (branch.falseCount == 0)
                    missing.push("false");
                if (missing.length > 0) {
                    insert(branch.pos.min, '<span class="missing" title="path${if (missing.length > 1) "s" else ""} not taken: ${missing.join(", ")}">');
                } else {
                    insert(branch.pos.min, '<span class="covered" title="paths taken: true=${branch.trueCount}, false=${branch.falseCount}">');
                }
                insert(branch.pos.max, '</span>');
            }

            for (statement in fileData.statements) {
                if (statement.count == 0) {
                    insert(statement.pos.min, '<span class="missing" title="statement not evaluated">');
                } else {
                    insert(statement.pos.min, '<span class="covered" title="statement evaluated ${statement.count} times">');
                }
                insert(statement.pos.max, '</span>');
            }

            var resultChars = [];
            for (i in 0...chars.length) {
                var ins = insertions[i];
                if (ins != null) {
                    for (c in ins)
                        resultChars.push(c);
                }
                resultChars.push(chars[i]);
            }

            output.push('<pre><code>');
            output.push(resultChars.join(""));
            output.push('</code></pre>');
        }

        return output.join("\n");
    }
}
