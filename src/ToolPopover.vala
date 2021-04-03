namespace Textpieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/tools-popover.ui")]
    class ToolsPopover : Gtk.Popover {
        [GtkChild]
        private unowned Gtk.TreeView tool_tree;
        [GtkChild]
        private unowned Gtk.SearchEntry search_entry;

        private Gtk.TreeModelFilter tree_model;

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
            clear_popover ();
            this.popdown ();
        }

        void clear_popover () {
            search_entry.set_text ("");
            tool_tree.set_cursor (new Gtk.TreePath.first (), null, false);
        }

        construct {
            hide.connect (clear_popover);

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

            tree_model = new Gtk.TreeModelFilter (store, null);
            tree_model.set_visible_func (filter_func);

            tool_tree.set_model (tree_model);
            tool_tree.set_cursor (
                new Gtk.TreePath.first(),
                null,
                false
            );
        }

        bool filter_func (Gtk.TreeModel model, Gtk.TreeIter iter) {
            Value value;
            model.get_value (iter, Column.NAME, out value);
            var tool_name = value.get_string();
            var search = new Search (search_entry.get_text ());
            return search.match (tool_name);
        }

        [GtkCallback]
        bool on_key_press_event (Gdk.EventKey e) {
            var key = e.keyval;
            switch (key) {
            case Gdk.Key.Up:
            case Gdk.Key.Down:
            case Gdk.Key.Return:
                Gtk.TreePath? _path;
                Gtk.TreeViewColumn? _col;
                tool_tree.get_cursor (out _path, out _col);

                var path = _path ?? new Gtk.TreePath.first ();
                var col = _col ?? (!) tool_tree.get_column (0);

                var n_tools = tree_model.iter_n_children (null);
                var index = path.get_indices ()[0];

                if (key == Gdk.Key.Up) {
                    if (index == 0)
                        path = new Gtk.TreePath.from_indicesv ({n_tools - 1});
                    else
                        path.prev ();
                }
                else if (key == Gdk.Key.Down) {
                    if (index == n_tools - 1)
                        path = new Gtk.TreePath.first ();
                    else
                        path.next ();
                }

                if (key == Gdk.Key.Return)
                    tool_tree.row_activated (path, col);

                tool_tree.set_cursor (
                    path,
                    col,
                    false
                );

                break;
            default:
                return false;
            }

            return true;
        }

        [GtkCallback]
        void on_search_changed () {
            tree_model.refilter ();
            if (tree_model.iter_n_children(null) != 0)
                tool_tree.set_cursor (new Gtk.TreePath.first (), null, false);
        }

        [GtkCallback]
        void on_row_activated (Gtk.TreePath path) {
            Gtk.TreeIter iter;
            tree_model.get_iter (out iter, path);
            Value val;
            tree_model.get_value (iter, Column.INDEX, out val);
            var index = val.get_int ();
            var tools = Textpieces.get_tools ();
            select_tool(tools[index]);
        }
    }
}