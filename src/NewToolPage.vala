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
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/NewToolPage.ui")]
    class NewToolPage : Gtk.Box {

        class Argument : Object {
            public int    index { get; construct; }
            public string name  { get; set;       }

            public Argument (int index) {
                Object (
                    index: index
                );
            }
        }

        [GtkChild] unowned Gtk.ListBox    argument_list;
        [GtkChild] unowned Gtk.SpinButton arguments_number;
        [GtkChild] unowned Gtk.Entry      name_entry;
        [GtkChild] unowned Gtk.Entry      description_entry;

        public Adw.PreferencesWindow window = null;

        private ListStore arguments_model;

        construct {
            /* Bind arguments model */
            var model = new ListStore (typeof (Argument));
            arguments_number.notify["value"].connect (() => {
                var value = arguments_number.value;
                while (value > model.get_n_items ())
                    model.append (new Argument ((int) model.get_n_items ()));
                while (value < model.get_n_items ())
                    model.remove (model.get_n_items () - 1);

                argument_list.visible = value > 0;
            });
            argument_list.bind_model (model, create_argument_row_func);
            arguments_model = model;
        }

        Gtk.Widget create_argument_row_func (Object item) {
            /* Get argument object */
            var argument = item as Argument;

            /* Create entry for argument name,
               align it to the center to don't
               stretch to the full height of row */
            var entry = new Gtk.Entry () {
                valign = CENTER
            };

            /* Create row itself,
               set title "Argument N",
               make entry activatable
               by click on row */
            var row = new Adw.ActionRow () {
                title = @"Argument $(argument.index + 1)",
                activatable_widget = entry
            };

            /* Add entry to row */
            row.add_suffix (entry);

            /* Bind entry text to
               argument name */
            entry.bind_property (
                "text",
                argument,
                "name"
            );

            return row;
        }

        [GtkCallback]
        void go_back () {
            window?.close_subpage ();
        }

        [GtkCallback]
        bool nonempty (string str) {
            return str != "";
        }

        [GtkCallback]
        void create () {
            /* Get tool name and description */
            var name        = name_entry.text;
            var description = description_entry.text;

            /* Get tool arguments */
            string[] arguments = {};
            for (int i = 0; i < arguments_model.get_n_items (); ++i) {
                var argument = (Argument) arguments_model.get_item (i);
                arguments += argument.name;
            }

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

            /* Create tool object */
            var tool = new Tool () {
                name = name,
                description = description,
                arguments = arguments,
                script = filename,
                is_system = false
            };

            /* Add new tool to tools */
            var tools = ((TextPieces.Application) window.application)
                            .tools;
            tools.custom_tools.append (tool);
            tools.dump_custom_tools ();

            /* Close subpage and open
               editor with script file */
            go_back ();
            tool.open (window);
        }
    }
}
