class HtmlReport {
    public static function report(coverage:coverme.Coverage, out:String) {
        var template = new haxe.Template(sys.io.File.getContent("bin/index.html.tpl"));

        var files = new Map();
        function getFileData(file) {
            var data = files[file];
            if (data == null)
                data = files[file] = {branches: [], statements: [], fields: []};
            return data;
        }

        for (branch in coverage.branches)
            getFileData(branch.pos.file).branches.push(branch);

        for (statement in coverage.statements)
            getFileData(statement.pos.file).statements.push(statement);

        for (field in coverage.fields)
            getFileData(field.pos.file).fields.push(field);

        var output = [];

        for (file in files.keys()) {
            output.push('<h1>$file</h1>');
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

        var html = template.execute({content: output.join("\n")});
        sys.io.File.saveContent(out, html);
    }
}
