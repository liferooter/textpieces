/* window.vala
 *
 * Copyright 2021 liferooter
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
 */

using Gtk, Gee;


namespace Textpieces {
    // Define type of tool function
    delegate string ToolFunc(string input);

    struct Tool {
        public string name;
        public ToolFunc func;
    }

	[GtkTemplate (ui = "/com/github/liferooter/textpieces/window.ui")]
	public class Window : ApplicationWindow {
		[GtkChild]
		ListBox tool_listbox;
		[GtkChild]
		Label tool_name;
		[GtkChild]
		Popover tool_popover;
		[GtkChild]
		TextBuffer text_buffer;
		[GtkChild]
		Button apply_button;
		[GtkChild]
		Button undo_button;

        uint _selected_tool;
		uint selected_tool { get { return _selected_tool; } set { _selected_tool = value; tool_name.set_text (current_tool.name); } }

		Tool current_tool { get { return TOOLS[selected_tool]; } }

		LinkedList<string> history = new LinkedList<string> ();

		// List of tools
        Tool[] TOOLS = {
            Tool () {
              name = "SHA256 Hash",
              func = (s) => Checksum.compute_for_string (ChecksumType.SHA256, s)
            },
            Tool () {
              name = "MD5 Hash",
              func = (s) => Checksum.compute_for_string (ChecksumType.MD5, s)
            },
            Tool () {
              name = "Base64 Coding",
              func = (s) => s
            }
        };

		public Window (Gtk.Application app) {
			Object (application: app);

			// Render tool list
            foreach (Tool tool in TOOLS) {
                ListBoxRow row = new ListBoxRow ();
                row.add (new Label (tool.name));

                tool_listbox.add (row);

                row.show_all ();
            }

            selected_tool = 0;

            // Select tool on click
            tool_listbox.row_activated.connect ((row) => {
                tool_popover.popdown  ();
                selected_tool = row.get_index();
            });

            // Connect apply button
            apply_button.clicked.connect((w) => {
                var old_text = text_buffer.text;
                if (text_buffer.has_selection) {
                    TextIter start, end;
                    text_buffer.get_selection_bounds (out start, out end);

                    var result = current_tool.func (text_buffer.get_text (start, end, false));
                    text_buffer.@delete (ref start, ref end);
                    text_buffer.insert (ref start, result, -1);
                }
                else
                    text_buffer.text = current_tool.func (text_buffer.text);

                if (old_text != text_buffer.text)
                    history.add (old_text);
            });

            // Set apply button sensitivity
            text_buffer.changed.connect (() => {
                apply_button.sensitive = text_buffer.text != "";

                if (history.size == 0)
                    undo_button.sensitive = text_buffer.text != "";
                else
                    undo_button.sensitive = text_buffer.text != history.last();
            });

            // Connect undo button
            undo_button.clicked.connect(() => {
                text_buffer.set_text (history.poll() ?? "");
            });
		}

	}
}
