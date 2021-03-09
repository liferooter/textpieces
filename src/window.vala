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

namespace Textpieces {
    // Define type of tool function
    public delegate string ToolFunc(string input);

    public struct Tool {
        public string name;
        public string icon;
        public ToolFunc func;
    }

	[GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/window.ui")]
	public class Window : Hdy.ApplicationWindow {
		[GtkChild]
		Gtk.ListBox tool_listbox;
		[GtkChild]
		Gtk.Entry tool_name;
		[GtkChild]
		Gtk.Popover tool_popover;
		[GtkChild]
		Gtk.SourceBuffer text_buffer;
        [GtkChild]
        Gtk.SourceView text_view;

        int _selected_tool = -1;
		int selected_tool { get { return _selected_tool; } set { _selected_tool = value; tool_name.set_text (current_tool.name); } }

		Tool? current_tool { get {
		    if (selected_tool == -1) {
		        return null;
		    } else {
		        return TOOLS[(uint) selected_tool];
		    }
		} }

		Gee.LinkedList<string> history = new Gee.LinkedList<string> ();
		Gee.LinkedList<string> reversed_history = new Gee.LinkedList<string> ();

        GLib.SimpleAction undo_action = new GLib.SimpleAction ("undo", null);
        GLib.SimpleAction apply_action = new GLib.SimpleAction ("apply", null);
        GLib.SimpleAction redo_action = new GLib.SimpleAction ("redo", null);
        GLib.SimpleAction show_keybindings = new GLib.SimpleAction ("show-keybindings", null);
        GLib.SimpleAction show_preferences = new GLib.SimpleAction ("show-preferences", null);

        Gtk.AccelGroup keybindings = new Gtk.AccelGroup ();

		// List of tools
        Tool[] TOOLS = {
            Tool () {
                name = "Hash - SHA1",
                icon = "fingerprint2-symbolic",
                func = (s) => Checksum.compute_for_string (ChecksumType.SHA1, s)
            },
            Tool () {
                name = "Hash - SHA256",
                icon = "fingerprint2-symbolic",
                func = (s) => Checksum.compute_for_string (ChecksumType.SHA256, s)
            },
            Tool () {
                name = "Hash - SHA384",
                icon = "fingerprint2-symbolic",
                func = (s) => Checksum.compute_for_string (ChecksumType.SHA384, s)
            },
            Tool () {
                name = "Hash - SHA512",
                icon = "fingerprint2-symbolic",
                func = (s) => Checksum.compute_for_string (ChecksumType.SHA512, s)
            },
            Tool () {
                name = "Hash - MD5",
                icon = "fingerprint2-symbolic",
                func = (s) => Checksum.compute_for_string (ChecksumType.MD5, s)
            },
            Tool () {
                name = "Base64 - Encode",
                icon = "size-right-symbolic",
                func = (s) => Base64.encode (s.data)
            },
            Tool () {
                name = "Base64 - Decode",
                icon = "size-left-symbolic",
                func = (s) => (string) Base64.decode (s)
            },
            Tool () {
                name = "Text - Trim trailing whitespaces",
                icon = "text-symbolic",
                func = (s) => s.strip()
            },
            Tool () {
                name = "Text - Count symbols",
                icon = "text-symbolic",
                func = (s) => s.length.to_string()
            },
            Tool () {
                name = "Text - Count lines",
                icon = "text-symbolic",
                func = (s) => {
                    var counter = 1;
                    for (var i = 0; i < s.length; i++) {
                        if (s[i] == '\n') {
                            counter++;
                        }
                    }
                    return counter.to_string();
                }
            }
        };

		public Window (Gtk.Application app) {
			Object (application: app);

			// Render tool list
            foreach (Tool tool in this.TOOLS) {

                // model_button.show();
                var row = new ToolRow (tool);
                this.tool_listbox.add (row);
            }

            // Set text changed handler
            this.text_buffer.changed.connect (this.validate_actions);

            // Show tool popover on click
            this.tool_name.grab_focus.connect ((e) => {
                this.tool_popover.popup ();
            });

            this.tool_listbox.row_activated.connect (this.select_tool_row);

            this.add_actions ();
			this.setup_keybindings ();
		}

		void setup_keybindings () {
		    this.keybindings.connect (
                Gdk.keyval_from_name ("question"),
                Gdk.ModifierType.CONTROL_MASK,
                0,
                () => {
                    this.show_keybindings.activate (null);
                    return true;
                }
		    );

		    this.keybindings.connect (
		        Gdk.keyval_from_name ("comma"),
		        Gdk.ModifierType.CONTROL_MASK,
		        0,
		        () => {
		            this.show_preferences.activate (null);
		            return true;
		        }
		    );

		    this.add_accel_group (this.keybindings);
		}

		void add_actions () {
            this.undo_action.activate.connect (() => {
                this.text_buffer.undo ();
            });
            this.redo_action.activate.connect (() => {
                this.text_buffer.redo ();
            });
            this.apply_action.activate.connect (apply);
            this.show_keybindings.activate.connect (() => {
                var shortcuts_window = new Textpieces.ShortcutsWindow (this);
                shortcuts_window.show_all ();
                shortcuts_window.present ();
            });
            this.show_preferences.activate.connect (() => {
                var preferences = new Textpieces.Preferences (this);
                preferences.show_all ();
                preferences.present ();
            });

            this.apply_action.set_enabled (false);

            this.add_action (this.undo_action);
            this.add_action (this.redo_action);
            this.add_action (this.apply_action);
            this.add_action (this.show_keybindings);
            this.add_action (this.show_preferences);
		}

		void select_tool_row (Gtk.ListBoxRow row) {
		    this.tool_name.primary_icon_name = ((ToolRow) row).tool_image.icon_name;
		    this.tool_popover.popdown  ();
            this.selected_tool = row.get_index ();
            this.validate_actions ();
		}

		void validate_actions () {
		    this.apply_action.set_enabled (this.text_buffer.text != "" && this.current_tool != null);
		}

		void apply () {
		    var old_text = this.text_buffer.text;
            if (this.text_buffer.has_selection) {
                Gtk.TextIter start, end;
                this.text_buffer.get_selection_bounds (out start, out end);

                var result = this.current_tool.func (this.text_buffer.get_text (start, end, false));

                this.text_buffer.@delete (ref start, ref end);
                this.text_buffer.insert (ref start, result, -1);
            }
            else
                this.text_buffer.text = this.current_tool.func (this.text_buffer.text);

            if (old_text != this.text_buffer.text)
                this.reversed_history.clear ();
                this.history.offer_head (old_text);
		}
	}
}
