namespace Textpieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/tools-popover.ui")]
    class ToolsPopover : Gtk.Popover {
        [GtkChild]
        private unowned Gtk.TreeView tool_tree;
        [GtkChild]
        private unowned Gtk.SearchEntry search_entry;

        public enum Column {
            NAME,
            ICON,
            INDEX,
            N_COLUMNS
        }

        public ToolsPopover (Gtk.Widget w) {
            Object (
                relative_to: w
            );
        }

        public virtual signal void select_tool (Tool tool) {
            this.popdown ();
        }

        construct {
            var store = new Gtk.ListStore (
                Column.N_COLUMNS,
                typeof (string),
                typeof (string),
                typeof (int)
            );

            store.set_sort_column_id (
                Column.NAME,
                Gtk.SortType.ASCENDING
            );

            {
                var renderer = new Gtk.CellRendererPixbuf ();
                renderer.set_padding (4, 4);
                renderer.stock_size = Gtk.IconSize.BUTTON;

                var column = new Gtk.TreeViewColumn ();
                column.pack_start (renderer, false);
                column.add_attribute (renderer, "icon-name", Column.ICON);
                tool_tree.append_column (column);
            }

            {
                var renderer = new Gtk.CellRendererText ();
                
                var column = new Gtk.TreeViewColumn ();
                column.pack_start (renderer, true);
                column.add_attribute (renderer, "text", Column.NAME);
                tool_tree.append_column (column);
            }

            {
                var tools = Textpieces.get_tools ();
                for (int i = 0; i < tools.length; i++) {
                    var tool = tools[i];
                    Gtk.TreeIter iter;
                    store.append (out iter);

                    store.set_value (iter, Column.NAME, tool.name);
                    store.set_value (iter, Column.ICON, tool.icon);
                    store.set_value (iter, Column.INDEX, i);
                }
            }

            var tree_model = new Gtk.TreeModelFilter (store, null);
            tree_model.set_visible_func ((model, iter) => {
                Value value;
                model.get_value (iter, Column.NAME, out value);
                var tool_name = value.get_string();
                var search = new Search (search_entry.get_text ());
                return search.match (tool_name);
            });

            search_entry.changed.connect (() => {
                tree_model.refilter ();
                Gtk.TreePath path;
                tool_tree.get_cursor (out path, null);
                if (tree_model.iter_n_children(null) != 0)
                    tool_tree.set_cursor (new Gtk.TreePath.first (), null, false);
            });

            tool_tree.set_model (tree_model);
            tool_tree.set_cursor (
                new Gtk.TreePath.first(),
                null,
                false
            );

            key_press_event.connect ((e) => {
                var key = e.keyval;
                if (key == Gdk.Key.Up || key == Gdk.Key.Down) {
                    Gtk.TreePath path;
                    tool_tree.get_cursor (out path, null);
                    if (path == null) {
                        return true;
                    }
                    var index = path.get_indices ()[0];
                    var n_columns = tree_model.iter_n_children (null);
                    switch (key) {
                        case Gdk.Key.Up:
                            if (index == 0)
                                path = new Gtk.TreePath.from_indices (n_columns - 1);
                            else
                                path.prev ();
                            break;
                        case Gdk.Key.Down:
                            if (index == n_columns - 1)
                                path = new Gtk.TreePath.first ();
                            else
                                path.next ();
                            break;
                    }
                    tool_tree.set_cursor (path, null, false);
                } else if (key == Gdk.Key.Escape) {
                    this.popdown ();
                } else if (key == Gdk.Key.Return) {
                    Gtk.TreePath path;
                    Gtk.TreeViewColumn col;
                    tool_tree.get_cursor (out path, out col);
                    tool_tree.row_activated (path, col);
                } else
                    return false;
                return true;
            });

            tool_tree.row_activated.connect ((path) => {
                Gtk.TreeIter iter;
                tree_model.get_iter (out iter, path);
                Value val;
                tree_model.get_value (iter, Column.INDEX, out val);
                var index = val.get_int ();
                var tools = Textpieces.get_tools ();
                select_tool(tools[index]);
            });
        }
    }
}