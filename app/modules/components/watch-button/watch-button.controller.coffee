###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: components/watch-button/watch-button.controller.coffee
###

class WatchButtonController
    @.$inject = [
        "tgCurrentUserService",
        "$rootScope",
        "tgLightboxFactory",
        "$translate"
    ]

    constructor: (@currentUserService, @rootScope, @lightboxFactory, @translate) ->
        @.user = @currentUserService.getUser()
        @.isMouseOver = false
        @.loading = false

    showTextWhenMouseIsOver: ->
        @.isMouseOver = true

    showTextWhenMouseIsLeave: ->
        @.isMouseOver = false

    openWatchers: ->
        onClose = (watchersIds) =>
            @rootScope.$broadcast("watchers:changed", watchersIds)

        @lightboxFactory.create(
            'tg-lb-select-user',
            {
                "class": "lightbox lightbox-select-user",
            },
            {
                "currentUsers": @.item.watchers,
                "activeUsers": @.activeUsers,
                "onClose": onClose,
                "lbTitle": @translate.instant("COMMON.WATCHERS.ADD"),
            }
        )

    getPerms: ->
        return "" if !@.item

        name = @.item._name

        perms = {
            userstories: 'modify_us',
            issues: 'modify_issue',
            tasks: 'modify_task',
            epics: 'modify_epic'
        }

        return perms[name]

    getWatchersTotal: ->
        return if !@.item
        activeWatchers = _.filter(@.activeUsers, (x) => _.includes(@.item.watchers, x.id))
        return activeWatchers.length

    toggleWatch: ->
        @.loading = true

        if not @.item.is_watcher
            promise = @._watch()
        else
            promise = @._unwatch()

        promise.finally () => @.loading = false

        return promise

    _watch: ->
        @.onWatch().then =>
            @.showTextWhenMouseIsLeave()

    _unwatch: ->
        @.onUnwatch()

angular.module("taigaComponents").controller("WatchButton", WatchButtonController)
