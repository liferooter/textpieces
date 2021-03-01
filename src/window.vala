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
		[GtkChild]
		Button redo_button;

        uint _selected_tool;
		uint selected_tool { get { return _selected_tool; } set { _selected_tool = value; tool_name.set_text (current_tool.name); } }

		Tool current_tool { get { return TOOLS[selected_tool]; } }

		LinkedList<string> history = new LinkedList<string> ();
		LinkedList<string> reversed_history = new LinkedList<string> ();

        SimpleAction undo_action = new SimpleAction ("undo", null);
        SimpleAction redo_action = new SimpleAction ("redo", null);
        SimpleAction apply_action = new SimpleAction ("apply", null);

		// List of tools
        Tool[] TOOLS = {
            Tool () {
              name = "Hash - SHA1",
              func = (s) => Checksum.compute_for_string (ChecksumType.SHA1, s)
            },
            Tool () {
              name = "Hash - SHA256",
              func = (s) => Checksum.compute_for_string (ChecksumType.SHA256, s)
            },
            Tool () {
              name = "Hash - SHA384",
              func = (s) => Checksum.compute_for_string (ChecksumType.SHA384, s)
            },
            Tool () {
              name = "Hash - SHA512",
              func = (s) => Checksum.compute_for_string (ChecksumType.SHA512, s)
            },
            Tool () {
              name = "Hash - MD5",
              func = (s) => Checksum.compute_for_string (ChecksumType.MD5, s)
            },
            Tool () {
              name = "Base64 - Encode",
              func = (s) => Base64.encode (s.data)
            },
            Tool () {
                name = "Base64 - Decode",
                func = (s) => (string) Base64.decode (s)
            },
            Tool () {
                name = "Text - Trim",
                func = (s) => {
                    var spaces_in_head = 0;
                    var spaces_in_tail = 0;
                    while (" \n".contains (s[spaces_in_head].to_string())) {
                        spaces_in_head++;
                    }
                    while (" \n".contains (s[s.length - spaces_in_tail - 1].to_string())) {
                        spaces_in_tail++;
                    }
                    return s[spaces_in_head : s.length - spaces_in_tail - 1];
                }
            }
        };

		public Window (Gtk.Application app) {
			Object (application: app);

			add_actions ();

			// Render tool list
            foreach (Tool tool in TOOLS) {
                ListBoxRow row = new ListBoxRow ();
                row.add (new Label (tool.name));

                tool_listbox.add (row);

                row.show_all ();
            }

            selected_tool = 0;

            // Select tool on click
            tool_listbox.row_activated.connect (select_tool_row);

            // Connect apply button
            // apply_button.clicked.connect(apply_tool);

            // Set text changed handler
            text_buffer.changed.connect (on_text_buffer_changed);

            // Connect undo button
            // undo_button.clicked.connect(undo);

            // Connect redo button
            // redo_button.clicked.connect(redo);
		}

		void add_actions () {
            undo_action.activate.connect (undo);
            redo_action.activate.connect (redo);
            apply_action.activate.connect (apply);

            undo_action.set_enabled (false);
            redo_action.set_enabled (false);
            apply_action.set_enabled (false);

            this.add_action (undo_action);
            this.add_action (redo_action);
            this.add_action (apply_action);
		}

		void select_tool_row (ListBoxRow row) {
		    tool_popover.popdown  ();
            selected_tool = row.get_index ();
		}

		void on_text_buffer_changed () {
		    apply_action.set_enabled (text_buffer.text != "");

            undo_action.set_enabled (history.size > 0 || text_buffer.text != "");
            redo_action.set_enabled (reversed_history.size != 0);
		}

		void apply () {
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
                reversed_history.clear ();
                history.offer_head (old_text);
		}

		void redo () {
		    history.offer_head (text_buffer.text);
            text_buffer.text = reversed_history.poll_head ();
		}

		void undo () {
		    var n = text_buffer.text != (history.peek_head() ?? "") ? 1 : 2;
		    reversed_history.offer_head (text_buffer.text);
		    for (int i = 0; i < n; i++) {
                text_buffer.text = history.poll_head () ?? "";
		    }
		}

	}
}
