// Copyright 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
// SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

namespace TextPieces {
    /**
     * Tools controller
     */
    class ToolsController : Object {
        /**
         * Configuration directory
         */
        static string CONFIG_DIR;

        /**
         * File containing
         * pre-installed tools metadata
         */
        static File SYSTEM_TOOLS_FILE;

        /**
         * File containing
         * custom tools metadata
         */
        static File CUSTOM_TOOLS_FILE;

        static construct {
            CONFIG_DIR = Path.build_filename (
                Environment.get_user_config_dir (), "textpieces"
            );

            CUSTOM_TOOLS_FILE = File.new_build_filename (
                CONFIG_DIR, "tools.json"
            );

            SYSTEM_TOOLS_FILE = File.new_build_filename (
                Config.PKGDATADIR, "tools.json"
            );
        }

        /**
         * List model of pre-installed tools
         */
        public ListStore system_tools = new ListStore (typeof (Tool));

        /**
         * List model of custom tools
         */
        public ListStore custom_tools = new ListStore (typeof (Tool));

        /**
         * List model of all tools
         */
        public ListStore all_tools {
            get; private set; default = new ListStore (typeof (Tool));
        }

        /**
         * Queue of deleted tools
         * pending script removal
         */
        private Queue<Tool> removed_tools = new Queue<Tool> ();

        construct {
            async_construct.begin ();
        }

        /**
         * Async construct
         */
        async void async_construct () {
            /* Create custom tools index if not exists */
            if (!CUSTOM_TOOLS_FILE.query_exists ()) {
                try {
                    yield save_custom_tools ();
                } catch (Error e) {
                    critical ("Can't create custom tools index: %s", e.message);
                }
            }

            yield update_tools ();
        }

        /**
         * Update tools
         */
        public async void update_tools () {
            /* Remove and load pre-installed tools */
            system_tools.remove_all ();
            var new_system_tools = load_tools_from_file (SYSTEM_TOOLS_FILE)
                ?? new ListStore (typeof (Tool));
            for (var i = 0; i < new_system_tools.get_n_items (); i++)
                system_tools.append (new_system_tools.get_item (i));

            /* Remove and load custom tools */
            custom_tools.remove_all ();
            var new_custom_tools = load_tools_from_file (CUSTOM_TOOLS_FILE)
                ?? new ListStore (typeof (Tool));
            for (var i = 0; i < new_custom_tools.get_n_items (); i++)
                custom_tools.append (new_custom_tools.get_item (i));

            /* Update model containing all tools */
            update_all_tools ();
        }

        /**
         * Update list model of all tools
         */
        void update_all_tools () {
            /* Remove all tools */
            all_tools.remove_all ();

            /* Append pre-installed tools */
            for (var i = 0; i < system_tools.get_n_items (); i++)
                all_tools.append (system_tools.get_item (i));

            /* Append custom tools */
            for (var i = 0; i < custom_tools.get_n_items (); i++)
                all_tools.append (custom_tools.get_item (i));
        }

        /**
         * Load tools from JSON file with tools metadata
         *
         * @param file metadata file
         *
         * @return list model containing loaded tools
         */
        private static ListStore load_tools_from_file (File file) {
            var tools = new ListStore (typeof (Tool));

            /* Return empty list model
               if file doesn't exist */
            if (!file.query_exists ()) {
                critical ("Can't load tools from non-existing file \"%s\"", file.get_path ());
                return tools;
            }

            /* Load JSON to parser */
            var parser = new Json.Parser ();
            try {
                parser.load_from_file (file.get_path ());
            } catch (Error e) {
                critical ("Can't load tools from \"%s\": %s", file.get_path (), e.message);
                return tools;
            }

            /* Get root object */
            var root = parser.get_root ();
            var obj = root?.get_object ();

            /* Return empty list if
               there are no root object */
            if (obj == null) {
                critical ("Can't load tools: file doesn't contain valid JSON object");
                return tools;
            }

            /* Get whether file contains
               pre-installed tools metadata */
            var is_system = obj.get_boolean_member_with_default (
                "is_system", false
            );

            /* Get tools array */
            var json_tools = obj.get_array_member ("tools");

            /* Return empty list model
               if there are no tools list */
            if (json_tools == null) {
                critical ("Can't load tools: file doesn't contain list of tools");
                return tools;
            }

            foreach (var json_tool in json_tools.get_elements ()) {
                /* Get tool object */
                var tool = json_tool.get_object ();

                if (tool == null) {
                    critical ("Error write loading tools: tool is not JSON object");
                    continue;
                }

                if (!tool.has_member ("script")) {
                    critical ("Error write loading tools: tool has no script");
                    continue;
                }

                string[] arguments = {};
                if (tool.has_member ("args"))
                    tool.get_array_member ("args").foreach_element ((a, i, node) => {
                        if (node.get_node_type () == VALUE
                            && node.get_value_type () == typeof (string)) {
                            arguments += node.get_string ();
                        } else {
                            critical ("Arguments of tools must be string");
                        }
                    });

                var new_tool = new Tool () {
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
                    is_system = is_system,
                    arguments = arguments
                };

                tools.append (new_tool);
            }

            return tools;
        }

        /**
         * Save custom tools' metadata
         */
        async void save_custom_tools ()
                throws Error {
            /* Ensure configuration directory exists */
            yield Utils.ensure_directory_exists (File.new_for_path (CONFIG_DIR));

            /* Create JSON builder */
            var builder = new Json.Builder ();

            // {
            builder.begin_object ();
            // "tools":
            builder.set_member_name ("tools");
            // [
            builder.begin_array ();

            /* Dump tools */
            for (var i = 0; i < custom_tools.get_n_items (); i++) {
                Tool tool = (Tool) custom_tools.get_item (i);

                // {
                builder
                    .begin_object ()
                // "name": `tool.name`,
                    .set_member_name ("name")
                    .add_string_value (tool.name)
                // "description": `tool.description`,
                    .set_member_name ("description")
                    .add_string_value (tool.description)
                // "script": `tool.script`,
                    .set_member_name ("script")
                    .add_string_value (tool.script)
                // "args": [
                    .set_member_name ("args")
                    .begin_array ();

                foreach (var arg in tool.arguments) {
                    // `arg`,
                    builder
                    .add_string_value (arg ?? "");
                }

                // ]
                builder
                    .end_array ();
                // },
                builder
                    .end_object ();
            }

            // ]
            builder.end_array ();
            // }
            builder.end_object ();

            /* Convert JSON builder to string... */
            var generator = new Json.Generator ();
            var node = builder.get_root ();
            generator.set_root (node);

            /* ...and save to file */
            try {
                generator.to_file (CUSTOM_TOOLS_FILE.get_path ());
            } catch (Error e) {
                error ("Can't save custom tools: %s", e.message);
            }
        }

        /**
         * Commit changed in custom tools
         */
        public async void commit ()
                throws Error {
            /* Save metadata on disk */
            yield save_custom_tools ();

            /* Update model of all tools */
            update_all_tools ();

            /* Delete scripts of removed tools */
            while (!removed_tools.is_empty ()) {
                var tool = removed_tools.pop_head ();
                /* Delete tool script */
                FileUtils.remove (
                    Path.build_filename (
                        Tool.CUSTOM_TOOLS_DIR,
                        tool.script
                    )
                );
            }
        }

        /**
         * Add and save tool
         *
         * @param tool custom tool to add
         */
        public signal void add_tool (Tool tool) {
            /* Append tool to model */
            custom_tools.append (tool);
        }

        public signal void delete_tool (Tool tool) {
            /* Remove tool from tools */
            uint pos;
            if (custom_tools.find (tool, out pos))
                custom_tools.remove (pos);

            removed_tools.push_tail (tool);
        }
    }
}
