function SS_TreeNavi(selector) {
  this.el = $(selector);
  this.closeMark = '<i class="material-icons">add</i>';
  this.openMark = '<i class="material-icons">remove</i>';
}

SS_TreeNavi.prototype.render = function(url) {
  this.url = url;
  this.registerEvents();
  this.refresh();
};

SS_TreeNavi.prototype.refresh = function() {
  var _this = this;
  var loading = $(SS.loading);

  if (! this.url) {
    return;
  }

  $.ajax({
    url: _this.url,
    beforeSend: function() {
      if (_this.errorEl) {
        _this.errorEl.hide();
      }
      _this.el.html(loading);
    },
    success: function(data) {
      _this.el.append(_this.renderItems(data.items, true));
    },
    error: function(xhr, status, error) {
      _this.showError(xhr, status, error);
    },
    complete: function() {
      loading.remove();
    }
  });
};

SS_TreeNavi.prototype.renderChildren = function(item) {
  var _this = this;
  var loading = $(SS.loading);

  $.ajax({
    url: $(item).find('.item-mark').attr('href'),
    data: 'only_children=1',
    beforeSend: function() {
      if (_this.errorEl) {
        _this.errorEl.hide();
      }
      item.after(loading);
    },
    success: function(data) {
      item.after(_this.renderItems(data.items, false));
    },
    error: function(xhr, status, error) {
      _this.showError(xhr, status, error);
    },
    complete: function() {
      loading.remove();
    }
  });
  return false;
};

SS_TreeNavi.prototype.renderItems = function(data, roots) {
  var _this = this;
  var ret = $.map(data, function(item) {
    var is_open, mark, cls;

    is_open = item.is_current || item.is_parent
    if (item.child_count === 0) {
      cls = ['is-close no-child'];
      mark = _this.openMark;
    } else if (is_open) {
      cls = ['is-open is-cache'];
      mark = _this.openMark;
    } else {
      cls = ['is-close'];
      mark = _this.closeMark;
    }
    if (item.is_current) cls.push('is-current');

    return '<div class="tree-item ' + cls.join(' ') + '" data-id="' + item.id + '" data-filename="' + item.filename + '"' + '>' +
      '<div class="item-pad"></div>'.repeat(item.depth - 1) +
      '<a class="item-mark" href="' + item.tree_url + '">' + mark + '</a>' +
      '<a class="item-name" href="' + item.url + '">' + item.name.replace('<','') + '</a>' +
      '</div>';
  });

  if (roots) {
    var $refresh = $("<a />", { class: "item-name", href: "#" });
    $refresh.html($("<span />", { class: "material-icons" }).text("refresh"));
    $refresh.on("click", function(ev) {
      _this.refresh();

      ev.preventDefault();
      return false;
    });

    ret.push($("<div />", { class: "tree-item content-navi-refresh" }).html($refresh));
  }

  return ret;
};

SS_TreeNavi.prototype.registerEvents = function() {
  var _this = this;
  this.el.on("click", ".tree-item .item-mark", function() {
    var $this = $(this);
    var item = $this.closest(".tree-item");

    if (!item.hasClass('no-child')) {
      if (item.hasClass('is-open')) {
        _this.closeItem(item, $(this));
      } else {
        _this.openItem(item, $(this));
      }
    }
    return false;
  })
};

SS_TreeNavi.prototype.openItem = function(item, mark) {
  item.addClass('is-open');
  mark.html(this.openMark);

  if (item.hasClass('no-child')) {
    return;
  }
  if (!item.hasClass('is-cache')) {
    this.renderChildren(item);
    return;
  }
  this.el.find('.tree-item').each(function () {
    if (!$(this).data('filename')) { return; }

    var filename = $(this).data('filename').toString();
    var path = item.data('filename').toString() + '/';
    if (filename.startsWith(path)) {
      $(this).show();
    }
  });
};

SS_TreeNavi.prototype.closeItem = function(item, mark) {
  item.addClass('is-cache');
  item.removeClass('is-open');
  mark.html(this.closeMark);

  this.el.find('.tree-item').each(function () {
    if (!$(this).data('filename')) { return; }

    var filename = $(this).data('filename').toString();
    var path = item.data('filename').toString() + '/';
    if (filename.startsWith(path)) {
      $(this).hide();
    }
  });
};

SS_TreeNavi.prototype.showError = function(xhr, status, error) {
  if (! this.errorEl) {
    this.errorEl = $('<div class="error" />');
    this.el.append(this.errorEl);
    this.errorEl.hide();
  }

  this.errorEl.html(error);
  this.errorEl.show();
};
