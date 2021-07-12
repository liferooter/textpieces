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
        [GtkChild]
        unowned Gtk.Switch run_on_host;

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
            tool.bind_property (
                "run-on-host", run_on_host,
                "state", BindingFlags.SYNC_CREATE
            );

            name_entry.text = tool.name;
            name_entry.changed.connect (on_tool_change);
            description_entry.text = tool.description;
            description_entry.changed.connect (on_tool_change);

            run_on_host.state_set.connect ((_, state) => {
                tool.run_on_host = state;
                tools.dump_custom_tools ();
                return false;
            });
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
        void on_delete () {
            tools.custom_tools.remove (get_index ());
            tools.dump_custom_tools ();

            ((Gtk.ListBox) parent).remove (this);
        }
    }
}
