/* NewToolPage.vala
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
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/NewToolPage.ui")]
    class NewToolPage : Gtk.Box {
        [GtkChild] unowned ToolSettings tool_settings;

        public Preferences prefs { get; construct; }

        private Tool new_tool;

        public NewToolPage (Preferences prefs) {
            Object (
                prefs: prefs
            );
        }

        construct {
            new_tool = new Tool () {
                name = "",
                description = "",
                arguments = {},
                script = "",
                is_system = false
            };

            tool_settings.set_tool (new_tool);
            tool_settings.window = prefs;
        }

        [GtkCallback]
        void go_back () {
            prefs?.close_subpage ();
        }

        [GtkCallback]
        void create () {
            /* Create tool directory if not exists */
            var dir = File.new_for_path (Tool.CUSTOM_TOOLS_DIR);
            if (!dir.query_exists ()) {
                try {
                    dir.make_directory_with_parents ();
                } catch (Error e) {
                    error ("Can't create directory for tool scripts: %s", e.message);
                }
            }

            /* Generate script filename with salt */
            var filename = Tool.generate_filename (name);

            /* Get script file */
            var script_file = File.new_build_filename (
                Tool.CUSTOM_TOOLS_DIR,
                filename
            );

            /* Get template file */
            var template_file = File.new_build_filename (
                Config.SCRIPTDIR,
                "template"
            );

            /* Copy template to file */
            try {
                template_file.copy (
                    script_file,
                    OVERWRITE
                );
            } catch (Error err) {
                error (@"Can't copy script template to file: $(err.message)");
            }

            /* Change file permissions */
            FileUtils.chmod (script_file.get_path (), 0750); // rwxr-x---

            /* Set script filename to the tool */
            new_tool.script = filename;

            /* Add new tool to tools */
            var tools = ((TextPieces.Application) prefs.application)
                            .tools;
            tools.custom_tools.append (new_tool);
            tools.dump_custom_tools ();

            /* Close subpage and open
               editor with script file */
            go_back ();
            new_tool.open (prefs);
        }
    }
}
