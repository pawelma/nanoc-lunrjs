/*
 * This script is modification of search from gem:
 * https://github.com/slashdotdash/jekyll-lunr-js-search (file: jquery.lunr.search.js)
 */

(function($) {

  var debounce = function(fn) {
    var timeout;
    var slice = Array.prototype.slice;

    return function() {
      var args = slice.call(arguments),
          ctx = this;

      clearTimeout(timeout);

      timeout = setTimeout(function () {
        fn.apply(ctx, args);
      }, 100);
    };
  };

  var directoryUp = function(uri){
    var directories = uri.directory().split('/');
    directories.pop();
    uri.directory(directories.join('/'));
  }

  var entryCounter = 0;

  var countEntry = function(){
    entryCounter += 1;
    return entryCounter;
  }

  var LunrSearch = (function() {
    function LunrSearch(elem, options) {
      uri = new URI(window.location.href.toString())
      this.$elem = elem;
      this.$results = $(options.results);
      this.$entries = $(options.entries, this.$results);
      this.entryCounter = 0;

      this.indexDataUrl = options.indexUrl;

      //hack for index data url in local filesystem
      if(uri.scheme() == 'file'){
        uri.file = uri.filename(this.indexDataUrl)
        while(uri.directory().indexOf('output/') >= 0){
          directoryUp(uri);
        }
        this.indexDataUrl = uri.toString();
      }

      this.index = this.createIndex();
      this.template = this.compileTemplate($(options.template));

      this.initialize();
    }

    LunrSearch.prototype.initialize = function() {
      var self = this;

      this.loadIndexData(function(data) {
        self.populateIndex(data);
        self.populateSearchFromQuery();
        self.bindKeypress();
      });
    };

    // create lunr.js search index specifying that we want to index the title and body fields of documents.
    LunrSearch.prototype.createIndex = function() {
      return lunr(function() {
        this.field('title', { boost: 10 });
        this.field('subtitle', { boost: 10});
        this.field('body');
        this.field('code');
        this.ref('id');
      });
    };

    // compile search results template
    LunrSearch.prototype.compileTemplate = function($template) {
      var template = $template.text();
      Mustache.parse(template);
      return function (view, partials) {
        return Mustache.render(template, view, partials);
      };
    };

    // load the search index data
    LunrSearch.prototype.loadIndexData = function(callback) {
      $.getJSON(this.indexDataUrl, callback).fail(function(){
        if(this.indexDataUrl.indexOf('file') >= 0){
          console.log('Cannot load '+ this.indexDataUrl + ' file. Try run WebServer to test search functionality (nanoc view).');
        }
        else{
          console.log('Cannot load' + this.indexDataUrl + ' file.');
        }
      });
    };

    LunrSearch.prototype.populateIndex = function(data) {
      var index = this.index;

      // format the raw json into a form that is simpler to work with
      this.entries = $.map(data, this.createEntry);

      $.each(this.entries, function(idx, entry) {
        index.add(entry);
      });
    };

    LunrSearch.prototype.createEntry = function(raw, index) {
      var entry = $.extend({
        id: countEntry(),
        url: index
      }, raw);

      return entry;
    };

    LunrSearch.prototype.bindKeypress = function() {
      var self = this;
      var oldValue = this.$elem.val();

      this.$elem.bind('keyup', debounce(function() {
        var newValue = self.$elem.val();
        if (newValue !== oldValue) {
          self.search(newValue);
        }

        oldValue = newValue;
      }));
    };

    LunrSearch.prototype.search = function(query) {
      var entries = this.entries;

      if (query.length < 2) {
        this.$results.hide();
        this.$entries.empty();
      } else {
        var results = $.map(this.index.search(query), function(result) {
          return $.grep(entries, function(entry) { return entry.id === parseInt(result.ref, 10); })[0];
        });

        this.displayResults(results);
      }
    };

    LunrSearch.prototype.displayResults = function(entries) {
      var $entries = this.$entries,
        $results = this.$results;

      $entries.empty();

      if (entries.length === 0) {
        $entries.append('<p>Nothing found.</p>');
      } else {
        $entries.append(this.template({entries: entries}));
      }

      $results.show();
    };

    // Populate the search input with 'q' querystring parameter if set
    LunrSearch.prototype.populateSearchFromQuery = function() {
      var uri = new URI(window.location.search.toString());
      var queryString = uri.search(true);

      if (queryString.hasOwnProperty('q')) {
        this.$elem.val(queryString.q);
        this.search(queryString.q.toString());
      }
    };

    return LunrSearch;
  })();

  $.fn.lunrSearch = function(options) {
    // apply default options
    options = $.extend({}, $.fn.lunrSearch.defaults, options);

    // create search object
    new LunrSearch(this, options);

    return this;
  };

  $.fn.lunrSearch.defaults = {
    indexUrl  : '/search.json',     // Url for the .json file containing search index source data (containing: title, url, date, body)
    results   : '#search-results',  // selector for containing search results element
    entries   : '.entries',         // selector for search entries containing element (contained within results above)
    template  : '#search-results-template'  // selector for Mustache.js template
  };
})(jQuery);
