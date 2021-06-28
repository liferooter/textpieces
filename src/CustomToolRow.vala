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

        Tool[]

        construct {
            bind_property (
                "title", name_entry,
                "text", BindingFlags.BIDIRECTIONAL
            );
            bind_property (
                "subtitle", description_entry,
                "text", BindingFlags.BIDIRECTIONAL
            );
        }

        [GtkCallback]
        void on_tool_change () {
            // Not Implemented Yet
            message ("TOOL CHANGED");
        }
    }
}
