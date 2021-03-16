namespace Textpieces {
    class Search  {
        string[] words;

        public Search (string key) {
            words = key.split (" ");
            for (var i = 0; i < words.length; i++) {
                words[i] = words[i].up();
            }
        }
        
        public bool match (string _text) {
            var text = _text.up ();
            var start = 0;
            foreach (var word in words) {
                var index = text.index_of (word, start);
                if (index == -1)
                    return false;
                else
                    start = index + word.length;
            }
            return true;
        }
    }
}