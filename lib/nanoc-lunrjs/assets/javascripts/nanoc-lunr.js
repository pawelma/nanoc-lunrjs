var index = null

function init_lunr_js(){
  index = lunr(function () {
    this.field('title', {boost: 10})
    this.field('subtitle', {boost: 10})
    this.field('body')
    this.field('code')
    this.ref('url')
  });
}

function apply_search_index(){

}

$(document).ready(function(){
  $('#nanoc-lunrjs-search').on('click', '.search-all', function(e){
    e.preventDefault();

  })
});
