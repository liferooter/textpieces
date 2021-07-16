/* NewToolDialog.vala
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
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/NewToolDialog.ui")]
    class NewToolDialog : Adw.Window {
        [GtkChild]
        unowned Gtk.Entry name_entry;
        [GtkChild]
        unowned Gtk.Entry description_entry;

        public Preferences preferences;
        public ToolsController tools;

        construct {}

        [GtkCallback]
        void create () {
            var tool = new Tool () {
                name = name_entry.get_text (),
                description = description_entry.get_text (),
                is_system = false,
                run_on_host = true
            };

            var script_file = File.new_build_filename (
                Tool.CUSTOM_TOOLS_DIR,
                tool.preferred_filename
            );

            var template_file = File.new_build_filename (
                Config.SCRIPTDIR,
                "template"
            );

            try {
                template_file.copy (
                    script_file,
                    FileCopyFlags.OVERWRITE,
                    null,
                    null
                );
            } catch (Error e) {
                error ("Can't create script from template: %s", e.message);
            }

            FileUtils.chmod (script_file.get_path (), 488);  // rwxr-x---

            tool.script = script_file.get_path ();

            tools.custom_tools.append (tool);
            tools.dump_custom_tools ();
            preferences.add_tool (tool);

            try {
                AppInfo.launch_default_for_uri (
                    "file://" + script_file.get_path (),
                    null
                );
            } catch (Error e) {
                error ("Can't open script: %s", e.message);
            }

            this.close ();
        }

        [GtkCallback]
        bool is_text_empty (uint text_length) {
            return text_length != 0;
        }
    }
}