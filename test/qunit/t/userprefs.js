'use strict';

(function() {
    var get = intermine.funcutils.get;

    module('User Preferences', TestCase);

    asyncTest('Set and clear: object', 2, function() {
        this.s.whoami(function(user) {
            user.setPreference({testPref: 'TestPrefVal'})
                .done(function() { equal(user.preferences.testPref, 'TestPrefVal'); })
                .then(_.bind(user.clearPreference, user, 'testPref'))
                .done(function() { ok(!user.preferences.testPref) })
                .always(start);
        });
    });
    asyncTest('Set and clear: object with multiple preferences', 4, function() {
        var args = {testPrefA: 'TestPrefValA', testPrefB: 'TestPrefValB'};
        this.s.whoami(function(user) {
            user.setPreferences(args)
                .done(function() { equal(user.preferences.testPrefA, 'TestPrefValA'); })
                .done(function() { equal(user.preferences.testPrefB, 'TestPrefValB'); })
                .then(function() { return $.when.apply($, _.map(_.keys(args), user.clearPreference)); })
                .done(function() { ok(!user.preferences.testPrefA, 'testPrefA is unset ' + user.preferences.testPrefA) })
                .done(function() { ok(!user.preferences.testPrefB, 'testPrefB is unset ' + user.preferences.testPrefB) })
                .always(start);
        });
    });

    asyncTest('Set and clear: array with multiple preferences', 4, function() {
        var args = [['testPrefA', 'TestPrefValA'], ['testPrefB', 'TestPrefValB']];
        this.s.whoami(function(user) {
            user.setPreferences(args)
                .done(function() { equal(user.preferences.testPrefA, 'TestPrefValA'); })
                .done(function() { equal(user.preferences.testPrefB, 'TestPrefValB'); })
                .then(function() { return $.when.apply($, args.map(get(0)).map(user.clearPreference)); })
                .done(function() { ok(!user.preferences.testPrefA, 'testPrefA is unset ' + user.preferences.testPrefA) })
                .done(function() { ok(!user.preferences.testPrefB, 'testPrefB is unset ' + user.preferences.testPrefB) })
                .always(start);
        });
    });

    asyncTest('Set and clear: name, val', 2, function() {
        this.s.whoami(function(user) {
            user.setPreference('testPref', 'TestPrefVal')
                .then(function() { equal(user.preferences.testPref, 'TestPrefVal'); })
                .then(_.bind(user.clearPreference, user, 'testPref'))
                .then(function() { ok(!user.preferences.testPref) })
                .always(start);
        });
    });
})();