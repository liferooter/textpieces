/* ToolsController.vala
 *
 * Copyright 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace TextPieces {
    class ToolsController : Object {

        static string CONFIG_DIR;

        static string SYSTEM_TOOLS_PATH;
        static string CUSTOM_TOOLS_PATH;

        static construct {
            CONFIG_DIR = Path.build_filename (
                Environment.get_user_config_dir (), "textpieces"
            );

            CUSTOM_TOOLS_PATH = Path.build_filename (
                CONFIG_DIR, "tools.json"
            );

            SYSTEM_TOOLS_PATH = Path.build_filename (
                Config.PKGDATADIR, "tools.json"
            );
        }

        public ListStore system_tools = new ListStore (typeof (Tool));
        public ListStore custom_tools = new ListStore (typeof (Tool));

        public ListStore all_tools {
            get; private set; default = new ListStore (typeof (Tool));
        }

        construct {
            update_tools ();
        }

        public void update_tools () {

            // Update system tools
            system_tools.remove_all ();
            var new_system_tools = load_tools_from_file (SYSTEM_TOOLS_PATH)
                ?? new ListStore (typeof (Tool));
            for (var i = 0; i < new_system_tools.get_n_items (); i++)
                system_tools.append (new_system_tools.get_item (i));

            // Update custom tools
            custom_tools.remove_all ();
            var new_custom_tools = load_tools_from_file (CUSTOM_TOOLS_PATH)
                ?? new ListStore (typeof (Tool));
            for (var i = 0; i < new_custom_tools.get_n_items (); i++)
                custom_tools.append (new_custom_tools.get_item (i));

            update_all_tools ();
        }

        void update_all_tools () {
            all_tools.remove_all ();

            for (var i = 0; i < system_tools.get_n_items (); i++)
                all_tools.append (system_tools.get_item (i));

            for (var i = 0; i < custom_tools.get_n_items (); i++)
                all_tools.append (custom_tools.get_item (i));

            all_tools.sort (
                (a, b) => {
                    if (((Tool) a).name > ((Tool) b).name) return 1;
                    else return -1;
                }
            );
        }

        private static ListStore? load_tools_from_file (string file) {
            if (!File.new_for_path (file).query_exists ())
                return null;

            var parser = new Json.Parser ();
            try {
                parser.load_from_file (file);
            } catch (Error e) {
                critical ("Can't load tools from \"%s\": %s", file, e.message);
                return null;
            }

            var root = parser.get_root (); if (root == null) return null;
            var obj = root.get_object (); if (obj == null) return null;
            var is_system = obj.get_boolean_member_with_default (
                "is_system", false
            );

            var json_tools = obj.get_array_member ("tools");
            if (json_tools == null) return null;

            var tools = new ListStore (typeof (Tool));

            foreach (var json_tool in json_tools.get_elements ()) {
                var tool = json_tool.get_object ();
                if (tool == null) return null;

                if (!tool.has_member ("script"))
                    continue;

                string[] arguments = {};
                if (tool.has_member ("args"))
                    tool.get_array_member ("args").foreach_element ((a, i, node) => {
                        if (node.get_node_type () == Json.NodeType.VALUE
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

        public void dump_custom_tools () {

            {
                var dir = File.new_for_path (CONFIG_DIR);
                if (!dir.query_exists ()) {
                    try {
                        dir.make_directory_with_parents ();
                    } catch (Error e) {
                        error ("Can't create directory for tool scripts: %s", e.message);
                    }
                }
            }

            var builder = new Json.Builder ();

            builder.begin_object ();
            builder.set_member_name ("tools");
            builder.begin_array ();

            // Load tools
            for (var i = 0; i < custom_tools.get_n_items (); i++) {
                Tool tool = (Tool) custom_tools.get_item (i);

                builder
                    .begin_object ()

                    .set_member_name ("name")
                    .add_string_value (tool.name)

                    .set_member_name ("description")
                    .add_string_value (tool.description)

                    .set_member_name ("script")
                    .add_string_value (tool.script)

                    .set_member_name ("args")
                    .begin_array ();

                foreach (var arg in tool.arguments) {
                    builder
                    .add_string_value (arg);
                }

                builder
                    .end_array ();

                builder
                    .end_object ();
            }

            builder.end_array ();
            builder.end_object ();

            var generator = new Json.Generator ();
            var node = builder.get_root ();
            generator.set_root (node);

            try {
                generator.to_file (CUSTOM_TOOLS_PATH);
            } catch (Error e) {
                error ("Can't dump custom tools: %s", e.message);
            }

            update_all_tools ();
        }

        public signal void delete_tool (Tool tool) {
            uint pos;
            custom_tools.find (tool, out pos);
            custom_tools.remove (pos);
            dump_custom_tools ();
        }
    }
}
