(function(globals) {
    exports = exports || globals;
    if (globals && typeof exports.intermine == 'undefined') {
        exports.intermine = {};
        exports = intermine;
    }

    var IS_NODE  = true;
    if (globals && globals.jQuery) {
        IS_NODE = false;
    }

    if (IS_NODE) {
        var _ = require('underscore')._;
    }

    var List = function(properties, service) {

        _(this).extend(properties);
        this.service = service;
        this.dateCreated = this.dateCreated ? new Date(this.dateCreated) : null;

        var isFolder = function(t) {
            return t.substr(0, t.indexOf(":")) === '__folder__';
        };
        var getFolderName = function(t) {
            return t.substr(t.indexOf(":") + 1);
        };

        this.folders = __(this.tags).filter(isFolder)
                                    .map(getFolderName)
                                    .value();
        
        this.hasTag = function(t) {
            return _(this.tags).include(t);
        };

        this.del = function(cb) {
            cb = cb || function() {};
            return this.service.makeRequest("lists", 
                {name: this.name}, cb, "DELETE");
        };

        this.contents = function(cb) {
            cb = cb || function() {};
            var query = {select: ["*"], from: this.type, where: {}};
            query.where[this.type] = {IN: this.name};
            return this.service.query(query, function(q) {
                q.records(cb);
            });
        };

        this.enrichment = function(data, cb) {
            data.list = this.name;
            return this.service.enrichment(data, cb);
        };
    };

    exports.List = List;
}).call(this);
        