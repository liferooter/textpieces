/* CustomTool.vala
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
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/CustomToolRow.ui")]
    class CustomToolRow : Adw.ExpanderRow {
        [GtkChild]
        unowned Gtk.Entry name_entry;
        [GtkChild]
        unowned Gtk.Entry description_entry;

        public Gtk.Window window;

        public ToolsController tools {get; construct set; }
        public Tool tool {get; construct set; }

        public CustomToolRow (Tool _tool, ToolsController _tools) {
            Object (
                tool: _tool,
                tools: _tools
            );
        }

        construct {
            tool.bind_property (
                "name", this,
                "title", BindingFlags.SYNC_CREATE
            );
            tool.bind_property (
                "description", this,
                "subtitle", BindingFlags.SYNC_CREATE
            );

            name_entry.text = tool.name;
            name_entry.changed.connect (on_tool_change);
            description_entry.text = tool.description;
            description_entry.changed.connect (on_tool_change);
        }

        void on_tool_change () {
            if (
                tool.name != name_entry.text
                || tool.description != description_entry.text
            ) {
                tool.name = name_entry.text;
                tool.description = description_entry.text;

                tools.dump_custom_tools ();
            }
        }

        [GtkCallback]
        void delete_tool () {
            var dialog = new Gtk.MessageDialog (
                window,
                Gtk.DialogFlags.MODAL,
                Gtk.MessageType.QUESTION,
                Gtk.ButtonsType.YES_NO,
                _("Do you really want to delete \"%s\" tool?"),
                tool.name
            );
            dialog.present ();

            dialog.response.connect ((res) => {
                if (res == Gtk.ResponseType.YES) {
                    set_expanded (false);
                    tools.custom_tools.remove (get_index ());
                    tools.dump_custom_tools ();

                    ((Gtk.ListBox) parent).remove (this);
                }
                dialog.destroy ();
            });
        }

        [GtkCallback]
        void open_script () {
            try {
                AppInfo.launch_default_for_uri (
                    "file://"
                    + Path.build_filename (
                        Tool.CUSTOM_TOOLS_DIR,
                        tool.script
                    ),
                    null
                );
            } catch (Error e) {
                error (@"Can't open script file: $(e.message)");
            }
        }

        [GtkCallback]
        void select_script () {
            var file_chooser = new Gtk.FileChooserNative (
                _("Select script"),
                window,
                Gtk.FileChooserAction.OPEN,
                null,
                null
            ){
                create_folders = false,
                modal = true
                //  transient_for = window
            };

            file_chooser.set_transient_for (window);

            file_chooser.response.connect ((id) => {
                if (id == Gtk.ResponseType.ACCEPT) {
                    var old_file = file_chooser.get_file ();

                    var new_file = File.new_build_filename (
                        Tool.CUSTOM_TOOLS_DIR,
                        tool.preferred_filename
                    );

                    old_file.copy_async.begin (
                        new_file,
                        FileCopyFlags.OVERWRITE,
                        Priority.HIGH_IDLE,
                        null,
                        null,
                        () => {
                            FileUtils.chmod (new_file.get_path (), 488); // rwxr-x---
                        }
                    );

                    tool.script = new_file.get_basename ();
                    tools.dump_custom_tools ();
                }
            });

            file_chooser.show ();
        }
    }
}
