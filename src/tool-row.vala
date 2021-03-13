/* tool-row.vala
 *
 * Copyright 2021 Liferooter <glebsmirnov0708@gmail.com>
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

using Gtk;

namespace Textpieces {

    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/tool-row.ui")]
    public class ToolRow : ListBoxRow {

        [GtkChild]
        Image tool_image;
        [GtkChild]
        Label tool_label;

        public Tool tool {get; construct; }

        public ToolRow (Tool _tool) {
            Object (
                tool: _tool
            );

            tool_label.set_text (tool.name);
            tool_image.icon_name = tool.icon;
        }
    }
}
