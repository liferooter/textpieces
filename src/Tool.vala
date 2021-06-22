namespace TextPieces {

    class Tool : Object {
        public string name;
        public string description;
        public string icon;
    }

    Gtk.FilterListModel get_tools (TextPieces.Window window) {
        var list = new ListStore (typeof (Tool));

        var system_tools = load_tools_from_file (Path.build_filename (Config.PKGDATADIR, "tools.json"));
        foreach (var tool in system_tools)
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

    Tool[] load_tools_from_file (string file) {
        var parser = new Json.Parser ();
        try {
            parser.load_from_file (file);
        } catch (Error e) {
            critical ("Can't load tools from \"%s\": %s", file, e.message);
            return {};
        }

        var root = parser.get_root (); if (root == null) return {};
        var obj = root.get_object (); if (obj == null) return {};
        var is_system = obj.get_boolean_member_with_default ("is_system", false);

        var scriptdir = is_system ? Config.SCRIPTDIR : Path.build_filename (Environment.get_user_data_dir (), "scripts");

        var json_tools = obj.get_array_member ("tools");
        if (json_tools == null) return {};

        Tool[] tools = {};

        foreach (var json_tool in json_tools.get_elements ()) {
            var tool = json_tool.get_object ();
            tools += new Tool () {
                name = tool.get_string_member ("name"),
                description = tool.get_string_member ("description"),
                icon = tool.get_string_member ("icon")
            };
        }

        return tools;
    }
}
