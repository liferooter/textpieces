namespace TextPieces {

    struct ScriptResult {
        string output;
        bool successful;
    }

    class Tool : Object {
        public string name;
        public string description;
        public string icon;
        public string script;
        public bool   is_system;
        public bool   run_on_host;

        public ScriptResult apply (string input) {
            var scriptdir = is_system
                ? Config.SCRIPTDIR
                : Path.build_filename (
                    Environment.get_user_data_dir (), "textpieces", "scripts"
                    );

            string cmdline = (
                    run_on_host
                        ? "flatpak-spawn --host "
                        : ""
                ) + Path.build_filename (scriptdir, script);

            try {
                var process = new Subprocess.newv (
                    cmdline.split (" "),
                    SubprocessFlags.STDIN_PIPE |
                    SubprocessFlags.STDOUT_PIPE |
                    SubprocessFlags.STDERR_PIPE
                );

                string stdout;
                string stderr;
                process.communicate_utf8 (input, null, out stdout, out stderr);

                bool success = process.get_successful ();

                return {
                    success
                        ? stdout ?? ""
                        : stderr ?? _("Error while running script"),
                    success
                };
            } catch (Error e) {
                return {
                    e.message,
                    false
                };
            }
        }
    }

    Gtk.FilterListModel get_tools (TextPieces.Window window) {
        var list = new ListStore (typeof (Tool));

        var system_tools = load_tools_from_file (
            Path.build_filename (Config.PKGDATADIR, "tools.json")
        );
        foreach (var tool in system_tools)
            list.append (tool);

        foreach (var tool in load_custom_tools ())
            list.append (tool);

        return new Gtk.FilterListModel (
            list,
            new Gtk.CustomFilter (
                window.tool_filter_func
            )
        );
    }

    Gtk.Widget build_list_row (Object item) {
        var tool = (Tool) item;

        return new Adw.ActionRow () {
            title = tool.name,
            subtitle = tool.description,
            icon_name = tool.icon,
            activatable = true
        };
    }

    Tool[] load_custom_tools () {
        var custom_tools_path = Path.build_filename (
            Environment.get_user_config_dir (), "textpieces", "tools.json"
        );
        if (File.new_for_path (custom_tools_path).query_exists ()) {
            return load_tools_from_file (custom_tools_path);
        } else return {};
    }

    void dump_custom_tools (Tool[] tools) {
        // Not Implemented Yet
        message ("DUMP TOOLS");
    }

    Tool[] load_tools_from_file (string file) {
        var parser = new Json.Parser ();
        try {
            parser.load_from_file (file);
        } catch (Error e) {
            critical (_("Can't load tools from \"%s\": %s"), file, e.message);
            return {};
        }

        var root = parser.get_root (); if (root == null) return {};
        var obj = root.get_object (); if (obj == null) return {};
        var is_system = obj.get_boolean_member_with_default (
            "is_system", false
        );

        var json_tools = obj.get_array_member ("tools");
        if (json_tools == null) return {};

        Tool[] tools = {};

        foreach (var json_tool in json_tools.get_elements ()) {
            var tool = json_tool.get_object (); if (tool == null) return {};

            if (!tool.has_member ("script")) {
                continue;
            }

            tools += new Tool () {
                name = tool.has_member ("name")
                    ? tool.get_string_member ("name")
                    : "",
                description = tool.has_member ("description")
                    ? tool.get_string_member ("description")
                    : "",
                icon = tool.has_member ("icon")
                    ? tool.get_string_member ("icon")
                    : "applications-utilities-symbolic",
                script = tool.get_string_member ("script"),
                run_on_host = tool.has_member ("run_on_host")
                    ? tool.get_boolean_member ("run_on_host")
                    : false,
                is_system = is_system,
            };
        }

        return tools;
    }
}
