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

        function row(cells:Array<String>, tag:String):String {
            var r = ["<tr>"];
            for (cell in cells)
                r.push('<$tag>$cell</$tag>');
            r.push("</tr>");
            return r.join("\n");
        }
        inline function tr(cells) return row(cells, "td");
        inline function trh(cells) return row(cells, "th");

        function stat(total:Int, covered:Int):String {
            var percent =
                if (total == 0)
                    0
                else
                    Math.round((covered / total) * 10000) / 100;

            return '$percent% ($covered / $total)';
        }

        var index = [
            "<h1>Packages</h1>"
        ];

        index.push("<table border>");
        index.push(trh([
            "name",
            "statements",
            "branches",
            "fields",
        ]));
        for (pack in coverage.packages) {
            var dotPath = pack.path.join(".");
            var packDir = if (dotPath == "") "root-package" else dotPath;
            sys.FileSystem.createDirectory('$outDir/$packDir');

            var packIndex = [
                '<h1>Package: ${if (dotPath == "") "<root package>".htmlEscape() else dotPath}</h1>',
                link("../index.html", "go up"),
            ];
            packIndex.push("<table border>");
            packIndex.push(trh([
                "name",
                "statements",
                "branches",
                "fields",
            ]));
            for (module in pack.modules) {
                sys.FileSystem.createDirectory('$outDir/$packDir/${module.name}');

                var moduleStr = pack.path.concat([module.name]).join(".");
                var moduleIndex = [
                    '<h1>Module: $moduleStr</h1>',
                    link("../index.html", "go up"),
                ];
                moduleIndex.push("<table border>");
                moduleIndex.push(trh([
                    "name",
                    "statements",
                    "branches",
                    "fields",
                ]));
                var firstType = null;
                for (type in module.types) {
                    if (firstType == null)
                        firstType = type.name;

                    var content = [
                        '<h1>Type: ${type.name} ($moduleStr)</h1>',
                        link("./index.html", "go up"),
                        "<table border>",
                        trh([
                            "statements",
                            "branches",
                            "fields",
                        ]),
                        tr([
                            stat(type.stats.statementsTotal, type.stats.statementsCovered),
                            stat(type.stats.branchesTotal, type.stats.branchesCovered),
                            stat(type.stats.fieldsTotal, type.stats.fieldsCovered),
                        ]),
                        "</table>",
                        renderTypePage(type),
                    ];

                    sys.io.File.saveContent('$outDir/$packDir/${module.name}/${type.name}.html', content.join("\n"));

                    moduleIndex.push(tr([
                        link('${type.name}.html', type.name),
                        stat(type.stats.statementsTotal, type.stats.statementsCovered),
                        stat(type.stats.branchesTotal, type.stats.branchesCovered),
                        stat(type.stats.fieldsTotal, type.stats.fieldsCovered),
                    ]));
                }
                moduleIndex.push("</table>");
                sys.io.File.saveContent('$outDir/$packDir/${module.name}/index.html', moduleIndex.join("\n"));

                packIndex.push(tr([
                    if (firstType != null && module.types.length == 1)
                        link('${module.name}/$firstType.html', module.name)
                    else
                        link('${module.name}/index.html', module.name),
                    stat(module.stats.statementsTotal, module.stats.statementsCovered),
                    stat(module.stats.branchesTotal, module.stats.branchesCovered),
                    stat(module.stats.fieldsTotal, module.stats.fieldsCovered),
                ]));

            }
            packIndex.push("</table>");
            sys.io.File.saveContent('$outDir/$packDir/index.html', packIndex.join("\n"));

            index.push(tr([
                link('$packDir/index.html', if (dotPath == "") "<root package>" else dotPath),
                stat(pack.stats.statementsTotal, pack.stats.statementsCovered),
                stat(pack.stats.branchesTotal, pack.stats.branchesCovered),
                stat(pack.stats.fieldsTotal, pack.stats.fieldsCovered),
            ]));
        }
        index.push("</table>");

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

        getFileData(type.pos.file);

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
.type {
    background-color: lightgray;
}

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

            insert(type.pos.min, '<span class="type" title="current type">');
            insert(type.pos.max, '</span>');

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
