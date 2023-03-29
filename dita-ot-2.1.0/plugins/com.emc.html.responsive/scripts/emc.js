/*jslint browser: true, eqeqeq: true, bitwise: true, newcap: true, immed: true, regexp: false */

/**
LazyLoad makes it easy and painless to lazily load one or more external
JavaScript or CSS files on demand either during or after the rendering of a web
page.

Supported browsers include Firefox 2+, IE6+, Safari 3+ (including Mobile
Safari), Google Chrome, and Opera 9+. Other browsers may or may not work and
are not officially supported.

Visit https://github.com/rgrove/lazyload/ for more info.

Copyright (c) 2011 Ryan Grove <ryan@wonko.com>
All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the 'Software'), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

@module lazyload
@class LazyLoad
@static
*/

LazyLoad = (function (doc) {
  // -- Private Variables ------------------------------------------------------

  // User agent and feature test information.
  var env,

  // Reference to the <head> element (populated lazily).
  head,

  // Requests currently in progress, if any.
  pending = {},

  // Number of times we've polled to check whether a pending stylesheet has
  // finished loading. If this gets too high, we're probably stalled.
  pollCount = 0,

  // Queued requests.
  queue = {css: [], js: []},

  // Reference to the browser's list of stylesheets.
  styleSheets = doc.styleSheets;

  // -- Private Methods --------------------------------------------------------

  /**
  Creates and returns an HTML element with the specified name and attributes.

  @method createNode
  @param {String} name element name
  @param {Object} attrs name/value mapping of element attributes
  @return {HTMLElement}
  @private
  */
  function createNode(name, attrs) {
    var node = doc.createElement(name), attr;

    for (attr in attrs) {
      if (attrs.hasOwnProperty(attr)) {
        node.setAttribute(attr, attrs[attr]);
      }
    }

    return node;
  }

  /**
  Called when the current pending resource of the specified type has finished
  loading. Executes the associated callback (if any) and loads the next
  resource in the queue.

  @method finish
  @param {String} type resource type ('css' or 'js')
  @private
  */
  function finish(type) {
    var p = pending[type],
        callback,
        urls;

    if (p) {
      callback = p.callback;
      urls     = p.urls;

      urls.shift();
      pollCount = 0;

      // If this is the last of the pending URLs, execute the callback and
      // start the next request in the queue (if any).
      if (!urls.length) {
        callback && callback.call(p.context, p.obj);
        pending[type] = null;
        queue[type].length && load(type);
      }
    }
  }

  /**
  Populates the <code>env</code> variable with user agent and feature test
  information.

  @method getEnv
  @private
  */
  function getEnv() {
    var ua = navigator.userAgent;

    env = {
      // True if this browser supports disabling async mode on dynamically
      // created script nodes. See
      // http://wiki.whatwg.org/wiki/Dynamic_Script_Execution_Order
      async: doc.createElement('script').async === true
    };

    (env.webkit = /AppleWebKit\//.test(ua))
      || (env.ie = /MSIE|Trident/.test(ua))
      || (env.opera = /Opera/.test(ua))
      || (env.gecko = /Gecko\//.test(ua))
      || (env.unknown = true);
  }

  /**
  Loads the specified resources, or the next resource of the specified type
  in the queue if no resources are specified. If a resource of the specified
  type is already being loaded, the new request will be queued until the
  first request has been finished.

  When an array of resource URLs is specified, those URLs will be loaded in
  parallel if it is possible to do so while preserving execution order. All
  browsers support parallel loading of CSS, but only Firefox and Opera
  support parallel loading of scripts. In other browsers, scripts will be
  queued and loaded one at a time to ensure correct execution order.

  @method load
  @param {String} type resource type ('css' or 'js')
  @param {String|Array} urls (optional) URL or array of URLs to load
  @param {Function} callback (optional) callback function to execute when the
    resource is loaded
  @param {Object} obj (optional) object to pass to the callback function
  @param {Object} context (optional) if provided, the callback function will
    be executed in this object's context
  @private
  */
  function load(type, urls, callback, obj, context) {
    var _finish = function () { finish(type); },
        isCSS   = type === 'css',
        nodes   = [],
        i, len, node, p, pendingUrls, url;

    env || getEnv();

    if (urls) {
      // If urls is a string, wrap it in an array. Otherwise assume it's an
      // array and create a copy of it so modifications won't be made to the
      // original.
      urls = typeof urls === 'string' ? [urls] : urls.concat();

      // Create a request object for each URL. If multiple URLs are specified,
      // the callback will only be executed after all URLs have been loaded.
      //
      // Sadly, Firefox and Opera are the only browsers capable of loading
      // scripts in parallel while preserving execution order. In all other
      // browsers, scripts must be loaded sequentially.
      //
      // All browsers respect CSS specificity based on the order of the link
      // elements in the DOM, regardless of the order in which the stylesheets
      // are actually downloaded.
      if (isCSS || env.async || env.gecko || env.opera) {
        // Load in parallel.
        queue[type].push({
          urls    : urls,
          callback: callback,
          obj     : obj,
          context : context
        });
      } else {
        // Load sequentially.
        for (i = 0, len = urls.length; i < len; ++i) {
          queue[type].push({
            urls    : [urls[i]],
            callback: i === len - 1 ? callback : null, // callback is only added to the last URL
            obj     : obj,
            context : context
          });
        }
      }
    }

    // If a previous load request of this type is currently in progress, we'll
    // wait our turn. Otherwise, grab the next item in the queue.
    if (pending[type] || !(p = pending[type] = queue[type].shift())) {
      return;
    }

    head || (head = doc.head || doc.getElementsByTagName('head')[0]);
    pendingUrls = p.urls.concat();

    for (i = 0, len = pendingUrls.length; i < len; ++i) {
      url = pendingUrls[i];

      if (isCSS) {
          node = env.gecko ? createNode('style') : createNode('link', {
            href: url,
            rel : 'stylesheet'
          });
      } else {
        node = createNode('script', {src: url});
        node.async = false;
      }

      node.className = 'lazyload';
      node.setAttribute('charset', 'utf-8');

      if (env.ie && !isCSS && 'onreadystatechange' in node && !('draggable' in node)) {
        node.onreadystatechange = function () {
          if (/loaded|complete/.test(node.readyState)) {
            node.onreadystatechange = null;
            _finish();
          }
        };
      } else if (isCSS && (env.gecko || env.webkit)) {
        // Gecko and WebKit don't support the onload event on link nodes.
        if (env.webkit) {
          // In WebKit, we can poll for changes to document.styleSheets to
          // figure out when stylesheets have loaded.
          p.urls[i] = node.href; // resolve relative URLs (or polling won't work)
          pollWebKit();
        } else {
          // In Gecko, we can import the requested URL into a <style> node and
          // poll for the existence of node.sheet.cssRules. Props to Zach
          // Leatherman for calling my attention to this technique.
          node.innerHTML = '@import "' + url + '";';
          pollGecko(node);
        }
      } else {
        node.onload = node.onerror = _finish;
      }

      nodes.push(node);
    }

    for (i = 0, len = nodes.length; i < len; ++i) {
      head.appendChild(nodes[i]);
    }
  }

  /**
  Begins polling to determine when the specified stylesheet has finished loading
  in Gecko. Polling stops when all pending stylesheets have loaded or after 10
  seconds (to prevent stalls).

  Thanks to Zach Leatherman for calling my attention to the @import-based
  cross-domain technique used here, and to Oleg Slobodskoi for an earlier
  same-domain implementation. See Zach's blog for more details:
  http://www.zachleat.com/web/2010/07/29/load-css-dynamically/

  @method pollGecko
  @param {HTMLElement} node Style node to poll.
  @private
  */
  function pollGecko(node) {
    var hasRules;

    try {
      // We don't really need to store this value or ever refer to it again, but
      // if we don't store it, Closure Compiler assumes the code is useless and
      // removes it.
      hasRules = !!node.sheet.cssRules;
    } catch (ex) {
      // An exception means the stylesheet is still loading.
      pollCount += 1;

      if (pollCount < 200) {
        setTimeout(function () { pollGecko(node); }, 50);
      } else {
        // We've been polling for 10 seconds and nothing's happened. Stop
        // polling and finish the pending requests to avoid blocking further
        // requests.
        hasRules && finish('css');
      }

      return;
    }

    // If we get here, the stylesheet has loaded.
    finish('css');
  }

  /**
  Begins polling to determine when pending stylesheets have finished loading
  in WebKit. Polling stops when all pending stylesheets have loaded or after 10
  seconds (to prevent stalls).

  @method pollWebKit
  @private
  */
  function pollWebKit() {
    var css = pending.css, i;

    if (css) {
      i = styleSheets.length;

      // Look for a stylesheet matching the pending URL.
      while (--i >= 0) {
        if (styleSheets[i].href === css.urls[0]) {
          finish('css');
          break;
        }
      }

      pollCount += 1;

      if (css) {
        if (pollCount < 200) {
          setTimeout(pollWebKit, 50);
        } else {
          // We've been polling for 10 seconds and nothing's happened, which may
          // indicate that the stylesheet has been removed from the document
          // before it had a chance to load. Stop polling and finish the pending
          // request to prevent blocking further requests.
          finish('css');
        }
      }
    }
  }

  return {

    /**
    Requests the specified CSS URL or URLs and executes the specified
    callback (if any) when they have finished loading. If an array of URLs is
    specified, the stylesheets will be loaded in parallel and the callback
    will be executed after all stylesheets have finished loading.

    @method css
    @param {String|Array} urls CSS URL or array of CSS URLs to load
    @param {Function} callback (optional) callback function to execute when
      the specified stylesheets are loaded
    @param {Object} obj (optional) object to pass to the callback function
    @param {Object} context (optional) if provided, the callback function
      will be executed in this object's context
    @static
    */
    css: function (urls, callback, obj, context) {
      load('css', urls, callback, obj, context);
    },

    /**
    Requests the specified JavaScript URL or URLs and executes the specified
    callback (if any) when they have finished loading. If an array of URLs is
    specified and the browser supports it, the scripts will be loaded in
    parallel and the callback will be executed after all scripts have
    finished loading.

    Currently, only Firefox and Opera support parallel loading of scripts while
    preserving execution order. In other browsers, scripts will be
    queued and loaded one at a time to ensure correct execution order.

    @method js
    @param {String|Array} urls JS URL or array of JS URLs to load
    @param {Function} callback (optional) callback function to execute when
      the specified scripts are loaded
    @param {Object} obj (optional) object to pass to the callback function
    @param {Object} context (optional) if provided, the callback function
      will be executed in this object's context
    @static
    */
    js: function (urls, callback, obj, context) {
      load('js', urls, callback, obj, context);
    }

  };
})(this.document);

/*
array.js - library to add methods to the array object
*/
//MDN version: adds indexOf() capacbilities to IE8
//https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/indexOf#Compatibility 
// Production steps of ECMA-262, Edition 5, 15.4.4.14
// Reference: http://es5.github.io/#x15.4.4.14
if (!Array.prototype.indexOf) {
  Array.prototype.indexOf = function(searchElement, fromIndex) {

    var k;

    // 1. Let O be the result of calling ToObject passing
    //    the this value as the argument.
    if (this == null) {
      throw new TypeError('"this" is null or not defined');
    }

    var O = Object(this);

    // 2. Let lenValue be the result of calling the Get
    //    internal method of O with the argument "length".
    // 3. Let len be ToUint32(lenValue).
    var len = O.length >>> 0;

    // 4. If len is 0, return -1.
    if (len === 0) {
      return -1;
    }

    // 5. If argument fromIndex was passed let n be
    //    ToInteger(fromIndex); else let n be 0.
    var n = +fromIndex || 0;

    if (Math.abs(n) === Infinity) {
      n = 0;
    }

    // 6. If n >= len, return -1.
    if (n >= len) {
      return -1;
    }

    // 7. If n >= 0, then Let k be n.
    // 8. Else, n<0, Let k be len - abs(n).
    //    If k is less than 0, then let k be 0.
    k = Math.max(n >= 0 ? n : len - Math.abs(n), 0);

    // 9. Repeat, while k < len
    while (k < len) {
      // a. Let Pk be ToString(k).
      //   This is implicit for LHS operands of the in operator
      // b. Let kPresent be the result of calling the
      //    HasProperty internal method of O with argument Pk.
      //   This step can be combined with c
      // c. If kPresent is true, then
      //    i.  Let elementK be the result of calling the Get
      //        internal method of O with the argument ToString(k).
      //   ii.  Let same be the result of applying the
      //        Strict Equality Comparison Algorithm to
      //        searchElement and elementK.
      //  iii.  If same is true, return k.
      if (k in O && O[k] === searchElement) {
        return k;
      }
      k++;
    }
    return -1;
  };
}

// File: _debug.js
// Description: Used for debugging purposes.  Instructions inline
// Dependency: _url.js / UW.url
(function(){
  UW.util.namespace("UW.debug");
  UW.debug = UW.util.extend(UW.debug, {
    // util: debug framework
    // desc: wipes any debug statements left in prod code (console.log and alerts on www.emc.com)
    //           creates a flag to expose console.log messages and alerts on prod if necessary
    //           if showing console.log messages, only does so if window.console is equal to true
    // use: UW.debug.log([log msg]);
    //          UW.debug.alert([alert msg]);
    flag:(function() {
        var debugCheck = false;
        var debugParam  = UW.url.search.indexOf('UW.debug=true') > 0 ? true : (UW.url.search.indexOf('UW.debug=false') > 0 ? false : undefined);
        var prodDomain  = UW.url.href.indexOf('//www.emc.com') > 0 ? true : false;
        if (((debugParam != true || debugParam == undefined) && prodDomain) || debugParam == false) {
          window.console={};
          window.console.log = function() {};
          
        } 
        if (debugParam || !prodDomain) {
          debugCheck = true;
        }
        return debugCheck;
    })(),
    log: function(args) { 
      if (this.flag && !!console) { 
        console.log(args);
      }
      else {} 
    },
    alert: function(args) { if (this.flag) { alert(args); } else {} }
  });
})();
// File: _util.js
// Purpose: Extends UW.util from _core.js 
(function(){
  UW.util = UW.util.extend(UW.util, {
    // util: creates a random number
    // use : takes parameter limit to set random max, default is 1000
    // e.g.: UW.util.getRandomNumber() or UW.util.getRandomNumber(50);
    getRandomNumber: function (limit) {
        if (!limit) { limit = 1000 };
        var sNum = Math.floor(Math.random() * limit) + 1;
        var sTime = (new Date).getTime();
        var rNum = sTime + "-" + sNum;
        return rNum;
    },

    /**
     *  Debounce funtion, named throttle for naming consistency with knockout
     *    @param {function} fn
     *    @param {Integer} delay /ms
     */
    throttle : function (fn, delay) {
        var timer = null;
        return function () {
            var context = this, args = arguments;
            clearTimeout(timer);
            timer = setTimeout(function () {
                fn.apply(context, args);
            }, delay);
        };
    },
    // util: gets URL parameter
    // use : determines the parameter from either the URL or a passed value
    // e.g.: grabs entire query string from URL
    //       UW.util.getUrlParameter();  
    // e.g.: grabs "lang" from URL
    //       UW.util.getUrlParameter("lang");
    // e.g.: grabs "lang" from passed URL value
    //       UW.util.getUrlParameter("lang", "http://www.test.com?lang=en&c=UK");
    getUrlParameter: function(param, url) {  
        var queryString;
        if(url){ queryString=url.slice(url.indexOf('?') + 1) };
        queryString = (queryString) ? queryString : window.location.search; 
        var val = "";
        var start = queryString.indexOf(param);
        if (start != -1) {
            start += param.length + 1;
            var end = queryString.indexOf("&", start);
            if (end == -1) {
                end = queryString.length
            }
            val = queryString.substring(start,end);
        }
        return val;
    },
    // util: sample function
    // use : simple example of new function formatting
    // e.g.: copy & paste to create a new function 
    demo:function() {
      var x = "success!";
      return x;
    },
    /**
     * Determinates if a given val should be considered as empty
     * 
     * @param {type} val
     * @returns {Boolean}
     */
    isEmptyVal: function (val) {
        'use strict';
        return undefined === val || null === val || "" === val; // do not use !val because 0 and false are not empty vals ;)
    },
    /**
     * Search a user defined property on the given source object
     * 
     * @param {object} source
     * @param {string} path dot notation property path through
     * @returns {(object|null|boolean|number|string|undefined)} Undefined only when property isn't defined or it's defined as undefined ( O.o weird )
     */
    getObjectProperty: function (source, path) {
        'use strict';

        var splittedPath = path.split('.'),
            splittedPathLength = splittedPath.length || 0,
            propertyName,
            currentProperty = source,
            i = 0;

        if (currentProperty && splittedPathLength) {
            for (i = 0; i < splittedPathLength; i += 1) {
                propertyName = splittedPath[i];

                if (currentProperty) {
                    currentProperty = currentProperty[propertyName];
                }

                if (UW.util.isEmptyVal(currentProperty)) {
                    break;
                }
            }
        }

        return currentProperty;
    },
    
    image: (function ($) {
        return  {
            srcSet: function (selector) {
                var $target = typeof selector !== 'undefined' && $(selector);
                
                    function setImage () {
                        var screenSize = UW.breakpoint.getScreenSize(),
                            deferred = new jQuery.Deferred();
                        
                        $($target).each(function () {
                            var newSrc = $(this).attr('data-src-' + screenSize) || $(this).attr('data-src-default');

                            if($(this).hasClass('bg-srcset')){
                                $(this).css('background-image', 'url(' + newSrc + ')');
                            }
                            else{
                                $(this).attr('src', newSrc);
                            }
                            
                        });
                        
                        deferred.resolve();
                        
                        return deferred.promise();
                    };

                    if ($target && $target.size()){
                        
                        // if the funtionallity has been already added, just set the image
                        // this allow changing the data-src-* values after render (e.g T&T) and
                        // set the correct img for the current viewport by calling UW.util.image.srcSet('.WHATEVER-PARENT .img-srcset')
                        if ($($target).data('srcSetListenerAdded')){
                            setImage();
                            return;
                        }

                        //Adding a fix for IE and FF, this is a temporal fix as we will fix the breakpoint handler.
                            setImage();
                        
                        UW.breakpoint.addBreakpointChangeListener().then(function (){
                            // let the element be aware the listener has been added
                            $($target).data('srcSetListenerAdded', true);
                            
                            // swap image everytime breakpoint changes
                            jQuery(window).on('breakpoint.changed', setImage);
                            
                        });
                    }
            }
        };
    }(jQuery)),
    // util: loader  
    // use : loads css or js assets via a 3rd party plugin (currently LazyLoad.js)
    //       @param urls = array of urls
    //       @callback = callback function 
    // e.g.: UW.util.loader.js(['http://use.typekit.net/fmn1ayd.js'], function(arg){
    //          console.log(arg);  
    //       });
    loader: (function () {
            //comenting the loader fix until we fixed it with promises
            //var list= [],
            var addURL = function(url){
                //find if it is absolute or relative path
                  if(url.search(/\/\//)==-1){
                      url="//"+ UW.url.hostscript + url;
                  }
                
                //if (list.indexOf(url)==-1){
                  //  list.push(url);
                    return url;
                //}else{
                    //return undefined;
                //}
                
            },    
            checkURLs= function(urls){
                if (typeof urls ==  "object"){
                    var newUrls=[];
                    var newUrl;
                    for (var i = 0; i<urls.length;i++){
                        newUrl=addURL(urls[i]);
                        if (newUrl){
                            newUrls.push(newUrl);
                        }
                    }
                    if (newUrls.length){
                        return newUrls;    
                    }
                }
                else{
                    return addURL(urls);
                }
                
                return undefined;
            };
            
            
        return {
            css: function(urls, callback, obj, context){
                LazyLoad.css(checkURLs(urls), callback, obj, context);
            },
            js: function(urls, callback, obj, context){
                var newURLs=checkURLs(urls);
                if(!newURLs && typeof callback == "function"){
                    callback();
                    return true;
                }
                LazyLoad.js(newURLs, callback, obj, context);
            }
        }
    })()
  
  });
    UW.locale=(function(){
        var locale=(jQuery("body").data("locale")||"en");
        return{
            locale:locale,   
            language:locale.split('-')[0],
            country:(locale.split('-')[1]||null)    
        }

    })();    
})();
/* polyfill-loader.js */

// iOS Orientation Change - BugFix
if (Modernizr.appleios) {
    UW.util.loader.js(['/etc/design/uwaem/manifests/js/dependencies/ios-orientationchange-fix.js']);
}

// Selectivr - Add CSS3 Support for Older Browsers like IE8 
if (!Modernizr.lastchild) {
    UW.util.loader.js(['/etc/designs/uwaem/manifests/js/polyfills/selectivizr-min.js']);
}

/*if (!Modernizr.csstransforms) {
    UW.util.loader.js(['/etc/designs/uwaem/manifests/js/polyfills/'], function() {
        console.log('t loaded');
        if (jQuery(".skew").length) {
            console.log('skew found');
            jQuery(".skew").each(function() {
                var deg = $(this).attr('data-skew');
console.log(deg);
                $(this).css({
                    transform: 'skew(' + deg + 'deg)'
                });
            });
        }
    });
}*/
/* <<< Start selectbox.js */
//
/*!
 * jQuery Selectbox plugin 0.2
 *
 * Copyright 2011-2012, Dimitar Ivanov (http://www.bulgaria-web-developers.com/projects/javascript/selectbox/)
 * Licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) license.
 * 
 * Date: Tue Jul 17 19:58:36 2012 +0300
 * Heavily Modified by Tom Callahan March 2014
 */
(function (e, t) {
    function s () {
        this._state = [];
        this._defaults = {
            classHolder: "sbHolder",
            classHolderDisabled: "sbHolderDisabled",
            classSelector: "sbSelector",
            classOptions: "sbOptions",
            classGroup: "sbGroup",
            classSub: "sbSub",
            classDisabled: "sbDisabled",
            classToggleOpen: "sbToggleOpen",
            classToggle: "sbToggle",
            classFocus: "sbFocus",
            speed: 100,
            effect: "slide",
            onChange: null,
            onOpen: null,
            onClose: null
        }
    }
    var n = "selectbox",
        r = false,
        i = true;
    e.extend(s.prototype, {
        _isOpenSelectbox: function (e) {
            if (!e) {
                return r
            }
            var t = this._getInst(e);
            return t.isOpen
        },
        _isDisabledSelectbox: function (e) {
            if (!e) {
                return r
            }
            var t = this._getInst(e);
            return t.isDisabled
        },
        _attachSelectbox: function (t, s) {

            function g () {
                var t, n, r = this.attr("id").split("_")[1];
                for (t in u._state) {
                    if (t !== r) {
                        if (u._state.hasOwnProperty(t)) {
                            n = e("select[sb='" + t + "']")[0];
                            if (n) {
                                u._closeSelectbox(n)
                            }
                        }
                    }
                }
            }

            function y () {
                var n = arguments[1] && arguments[1].sub ? true : false,
                    r = arguments[1] && arguments[1].disabled ? true : false;
                arguments[0].each(function (s) {
                    var o = e(this),
                        f = e("<li>"),
                        d;
                    if (o.is(":selected")) {
                        l.text(o.text());
                        p = i
                    }
                    if (s === m - 1) {
                        f.addClass("last")
                    }
                    if (!o.is(":disabled") && !r) {
                        d = e("<a>", {
                            href: "#" + o.val(),
                            rel: o.val()
                        }).text(o.text()).bind("click.sb", function (n) {
                            if (n && n.preventDefault) {
                                n.preventDefault()
                            }
                            var r = c,
                                i = e(this),
                                s = r.attr("id").split("_")[1];
                            u._changeSelectbox(t, i.attr("rel"), i.text());
                            u._closeSelectbox(t)
                        }).bind("mouseover.sb", function () {
                            var t = e(this);
                            t.parent().siblings().find("a").removeClass(a.settings.classFocus);
                            t.addClass(a.settings.classFocus)
                        }).bind("mouseout.sb", function () {
                            e(this).removeClass(a.settings.classFocus)
                        });
                        if (n) {
                            d.addClass(a.settings.classSub)
                        }
                        if (o.is(":selected")) {
                            d.addClass(a.settings.classFocus)
                        }
                        d.appendTo(f)
                    } else {
                        d = e("<span>", {
                            text: o.text()
                        }).addClass(a.settings.classDisabled);
                        if (n) {
                            d.addClass(a.settings.classSub)
                        }
                        d.appendTo(f)
                    }
                    f.appendTo(h)
                })
            }
            if (this._getInst(t)) {
                return r
            }
            var o = e(t),
                u = this,
                a = u._newInst(o),
                f, l, c, h, p = r,
                d = o.find("optgroup"),
                v = o.find("option"),
                m = v.length;
            o.attr("sb", a.uid);
            e.extend(a.settings, u._defaults, s);
            u._state[a.uid] = r;
            o.hide();
            f = e("<div>", {
                id: "sbHolder_" + a.uid,
                "class": a.settings.classHolder,
                tabindex: o.attr("tabindex")
            });
            l = e("<a>", {
                id: "sbSelector_" + a.uid,
                href: "#",
                "class": a.settings.classSelector,
                click: function (n) {
                    n.preventDefault();
                    g.apply(e(this), []);
                    var r = e(this).attr("id").split("_")[1];
                    if (u._state[r]) {
                        u._closeSelectbox(t)
                    } else {
                        u._openSelectbox(t)
                    }
                }
            });
            c = e("<a>", {
                id: "sbToggle_" + a.uid,
                href: "#",
                "class": a.settings.classToggle,
                click: function (n) {
                    n.preventDefault();
                    g.apply(e(this), []);
                    var r = e(this).attr("id").split("_")[1];
                    if (u._state[r]) {
                        u._closeSelectbox(t)
                    } else {
                        u._openSelectbox(t)
                    }
                }
            });
            c.appendTo(f);
            h = e("<ul>", {
                id: "sbOptions_" + a.uid,
                "class": a.settings.classOptions,
                css: {
                    display: "none"
                }
            });
            o.children().each(function (t) {
                var n = e(this),
                    r, i = {};
                if (n.is("option")) {
                    y(n)
                } else if (n.is("optgroup")) {
                    r = e("<li>");
                    e("<span>", {
                        text: n.attr("label")
                    }).addClass(a.settings.classGroup).appendTo(r);
                    r.appendTo(h);
                    if (n.is(":disabled")) {
                        i.disabled = true
                    }
                    i.sub = true;
                    y(n.find("option"), i)
                }
            });
            if (!p) {
                l.text(v.first().text())
            }
            e.data(t, n, a);
            f.data("uid", a.uid).bind("keydown.sb", function (t) {
                var r = t.charCode ? t.charCode : t.keyCode ? t.keyCode : 0,
                    i = e(this),
                    s = i.data("uid"),
                    o = i.siblings("select[sb='" + s + "']").data(n),
                    a = i.siblings(["select[sb='", s, "']"].join("")).get(0),
                    f = i.find("ul").find("a." + o.settings.classFocus);
                switch (r) {
                    case 37:
                    case 38:
                        if (f.length > 0) {
                            var l;
                            e("a", i).removeClass(o.settings.classFocus);
                            l = f.parent().prevAll("li:has(a)").eq(0).find("a");
                            if (l.length > 0) {
                                l.addClass(o.settings.classFocus).focus();
                                e("#sbSelector_" + s).text(l.text())
                            }
                        }
                        break;
                    case 39:
                    case 40:
                        var l;
                        e("a", i).removeClass(o.settings.classFocus);
                        if (f.length > 0) {
                            l = f.parent().nextAll("li:has(a)").eq(0).find("a")
                        } else {
                            l = i.find("ul").find("a").eq(0)
                        }
                        if (l.length > 0) {
                            l.addClass(o.settings.classFocus).focus();
                            e("#sbSelector_" + s).text(l.text())
                        }
                        break;
                    case 13:
                        if (f.length > 0) {
                            u._changeSelectbox(a, f.attr("rel"), f.text())
                        }
                        u._closeSelectbox(a);
                        break;
                    case 9:
                        if (a) {
                            var o = u._getInst(a);
                            if (o) {
                                if (f.length > 0) {
                                    u._changeSelectbox(a, f.attr("rel"), f.text())
                                }
                                u._closeSelectbox(a)
                            }
                        }
                        var c = parseInt(i.attr("tabindex"), 10);
                        if (!t.shiftKey) {
                            c++
                        } else {
                            c--
                        }
                        e("*[tabindex='" + c + "']").focus();
                        break;
                    case 27:
                        u._closeSelectbox(a);
                        break
                }
                t.stopPropagation();
                return false
            }).delegate("a", "mouseover", function (t) {
                e(this).addClass(a.settings.classFocus)
            }).delegate("a", "mouseout", function (t) {
                e(this).removeClass(a.settings.classFocus)
            });
            l.appendTo(f);
            h.appendTo(f);
            f.insertAfter(o);
            e("html").live("mousedown", function (t) {
                t.stopPropagation();
                e("select").selectbox("close")
            });
            e([".", a.settings.classHolder, ", .", a.settings.classSelector].join("")).mousedown(function (e) {
                e.stopPropagation()
            })
        },
        _detachSelectbox: function (t) {
            var i = this._getInst(t);
            if (!i) {
                return r
            }
            e("#sbHolder_" + i.uid).remove();
            e.data(t, n, null);
            e(t).show()
        },
        _changeSelectbox: function (t, n, s) {
            var o, u = this._getInst(t);
            if (u) {
                o = this._get(u, "onChange");
                var temp = s;
                e("#sbSelector_" + u.uid).text(temp);
                while (e("#sbSelector_" + u.uid).height() > 20) {
                    temp = temp.slice(0, -1);
                    e("#sbSelector_" + u.uid).html(temp + '&hellip;');
                }
            }
            n = n.replace(/\'/g, "\\'");
            e(t).find("option").attr("selected", r);
            e(t).find("option[value='" + n + "']").attr("selected", i);
            if (u && o) {
                o.apply(u.input ? u.input[0] : null, [n, u])
            } else if (u && u.input) {
                u.input.trigger("change")
            }
        },
        _enableSelectbox: function (t) {
            var i = this._getInst(t);
            if (!i || !i.isDisabled) {
                return r
            }
            e("#sbHolder_" + i.uid).removeClass(i.settings.classHolderDisabled);
            i.isDisabled = r;
            e.data(t, n, i)
        },
        _disableSelectbox: function (t) {
            var s = this._getInst(t);
            if (!s || s.isDisabled) {
                return r
            }
            e("#sbHolder_" + s.uid).addClass(s.settings.classHolderDisabled);
            s.isDisabled = i;
            e.data(t, n, s)
        },
        _optionSelectbox: function (t, i, s) {
            var o = this._getInst(t);
            if (!o) {
                return r
            }
            o[i] = s;
            e.data(t, n, o)
        },
        _openSelectbox: function (t) {
            var r = this._getInst(t);
            if (!r || r.isOpen || r.isDisabled) {
                return
            }
            var s = e("#sbOptions_" + r.uid),
                o = parseInt(e(window).height(), 10),
                u = e("#sbHolder_" + r.uid).offset(),
                a = e(window).scrollTop(),
                f = s.prev().outerHeight(),
                l = o - (u.top - a) - f / 2,
                c = this._get(r, "onOpen");
            s.css({
                display: "block",
                height: "0px"
            });
            var h = 0;
            var p = 0;
            s.find("li").each(function (t, n) {
                if (t > 0) {
                    h += e(n).outerHeight()
                }
                p = $j(n).outerHeight()
            });
            h = Math.min(h, p * 8);
            switch (r.settings.effect) {
                case "up":
                    s.css({
                        top: "auto",
                        bottom: f + "px"
                    });
                    break;
                default:
                    s.css({
                        top: f + "px",
                        bottom: "auto"
                    })
            }
            s.animate({
                height: h + "px"
            }, 200);
            e("#sbToggle_" + r.uid).addClass(r.settings.classToggleOpen);
            this._state[r.uid] = i;
            r.isOpen = i;
            if (c) {
                c.apply(r.input ? r.input[0] : null, [r])
            }
            e.data(t, n, r)
        },
        _closeSelectbox: function (t) {
            var i = this._getInst(t);
            if (!i || !i.isOpen) {
                return
            }
            var s = e("#sbOptions_" + i.uid);
            var o = this._get(i, "onClose");
            s.animate({
                height: "0px"
            }, 200, function () {
                s.css("display", "none")
            });
            e("#sbToggle_" + i.uid).removeClass(i.settings.classToggleOpen);
            this._state[i.uid] = r;
            i.isOpen = r;
            if (o) {
                o.apply(i.input ? i.input[0] : null, [i])
            }
            e.data(t, n, i)
        },
        _newInst: function (e) {
            var t = e[0].id.replace(/([^A-Za-z0-9_-])/g, "\\\\$1");
            return {
                id: t,
                input: e,
                uid: Math.floor(Math.random() * 99999999),
                isOpen: r,
                isDisabled: r,
                settings: {}
            }
        },
        _getInst: function (t) {
            try {
                return e.data(t, n)
            } catch (r) {
                throw "Missing instance data for this selectbox"
            }
        },
        _get: function (e, n) {
            return e.settings[n] !== t ? e.settings[n] : this._defaults[n]
        }
    });
    e.fn.selectbox = function (t) {
        var n = Array.prototype.slice.call(arguments, 1);
        if (typeof t == "string" && t == "isDisabled") {
            return e.selectbox["_" + t + "Selectbox"].apply(e.selectbox, [this[0]].concat(n))
        }
        if (t == "option" && arguments.length == 2 && typeof arguments[1] == "string") {
            return e.selectbox["_" + t + "Selectbox"].apply(e.selectbox, [this[0]].concat(n))
        }
        return this.each(function () {
            typeof t == "string" ? e.selectbox["_" + t + "Selectbox"].apply(e.selectbox, [this].concat(n)) : e.selectbox._attachSelectbox(this, t)
        })
    };
    e.selectbox = new s;
    e.selectbox.version = "0.2"
})(jQuery);

/* >>> End of selectbox.js */
/* <<< Start emc-domain-map.js */
/*
 * 
 * This code was extracted from responsive-header.js FROM LINE 1618 to 1793
 */

    var $j= $j ? $j : jQuery.noConflict();
    var j= j ? j : jQuery.noConflict();

    /* Domain/Locale mappings */
    var emcDomainMap={};
    var emcDomainMapP9={};
    var emcDomainDisplayNameMap={};

    var sides=['a','b'];
    var envsWithoutSides=['stageprev','preview','stage']; // the order here is important, always put the "prev" versions before the regular versions
    var envsWithSides=['testprev[]','test[]','devprev[]','dev[]'];

    // full subdomain, p9 fallback lang, country code
 var langMapNew=[
['www','en_US','en_US','United States'],
['afrique','fr_FR','fr_AF','Afrique'],
    //['southamerica','en_US','en_US','South America'], // does not exist in AEM?
['apj','en_US','en_US','APJ'],
['argentina','es_MX','es_AR','Argentina'],
['austria','de_DE','de_AT','Austria'],
['australia','en_US','en_AU','Australia'],
['belgium','en_US','fr_BE','Belgium'],
['brazil','pt_BR','pt_BR','Brazil'],
['canada','en_US','en_CA','Canada'],
['chile','es_MX','es_CL','Chile'],
['china','zh_CN','zh_CN','China'],
['colombia','es_MX','es_CO','Colombia'],
['czech','en_US','cs_CZ','Czech Republic'],
['germany','de_DE','de_DE','Germany'],
['switzerland','de_DE','de_CH','Switzerland'],
['denmark','en_US','da_DK','Denmark'],
['estonia','en_US','et_EE','Estonia'],
['emea','en_US','en_US','EMEA'],
['spain','es_MX','es_ES','Spain'],
['finland','en_US','fi_FI','Finland'],
['france','fr_FR','fr_FR','France'],
['suisse','fr_FR','fr_CH','Suisse'],
['uk','en_US','en_GB','United Kingdom'],
['greece','en_US','el_GR','Greece'],
['hk','en_US','zh_HK','Hong Kong'],
['hungary','en_US','hu_HU','Hungary'],
['indonesia','en_US','id_ID','Indonesia'],
['ireland','en_US','en_IE','Ireland'],
['israel','en_US','he_IL','Israel'],
['india','en_US','hi_IN','India'],
['italy','it_IT','it_IT','Italy'],
['japan','ja_JP','ja_JP','Japan'],
['korea','ko_KR','ko_KR','Korea'],
['lithuania','en_US','lb_LU','Lithuania'],
['luxembourg','en_US','lt_LT','Luxembourg'],
['latvia','en_US','lv_LV','Latvia'],
['mexico','es_MX','es_MX','Mexico'],
['malaysia','en_US','ms_MY','Malaysia'],
['netherlands','en_US','nl_NL','Netherlands'],
['norway','en_US','nb_NO','Norway'],
['peru','es_MX','es_PE','Peru'],
['philippines','en_US','en_PH','Philippines'],
['poland','en_US','pl_PL','Poland'],
['puertorico','es_MX','es_PR','Puerto Rico'],
['portugal','pt_BR','pt_PT','Portugal'],
['russia','ru_RU','ru_RU','Russia'],
['middleeast','en_US','en_ME','Middle East'],
['sweden','en_US','sv_SE','Sweden'],
['singapore','en_US','zh_SG','Singapore'],
['slovenia','en_US','sl_SL','Slovenia'],
    //['slovakia','en_US','sk_SK','Slovakia'], // does not exist in AEM?
['thailand','en_US','th_TH','Thailand'],
['turkey','en_US','tr_TR','Turkey'],
['taiwan','en_US','zh_TW','Taiwan'],
['ukraine','ru_RU','uk_UA','Ukraina'],
['venezuela','es_MX','es_VE','Venezuela'],
['vietnam','en_US','vi_VN','Vietnam'],
['southafrica','en_US','en_ZA','South Africa'],
['saudi','en_US','ar_SA','Saudi Arabia'],
['africa','en_US','en_AF','Africa'],
['gambia','en_US','en_GM','Gambia'],
['ghana','en_US','en_GH'],'Ghana',
['kenya','en_US','sw_KE'],'Kenya',
    //['cameroon','en_US','en_US','Cameroon'], // does not exist in AEM?
['liberia','en_US','en_LR','Liberia'],
['nigeria','en_US','en_NG','Nigeria'],
['rwanda','en_US','rw_RW','Rwanda'],
    //['sierraleone','en_US','  en_US','Sierra Leone'], // does not exist in AEM?
['tanzania','en_US','en_TZ','Tanzania'],
['uganda','en_US','en_UG','Uganda'],
['zambia','en_US','en_ZM','Zambia'],
['cameroun','en_US','fr_CM','Cameroun'],
['cotedivoire','en_US','fr_CI','Cote d\'Ivoire'],
['gabon','en_US','fr_GA','Gabon'],
['madagascar','en_US','fr_MG','Madagascar'],
['maroc','fr_FR','fr_MA','Morocco'],
    //['algeria','fr_FR','fr_AF','Algeria'], // does not exist in AEM?
['senegal','en_US','fr_SN','Senegal'],
['see','en_US','en_US','South-East Europe'],
['romania','en_US','ro_RO','Romania'],
['croatia','en_US','hr_HR','Croatia'],
['serbia','en_US','sr_BA','Serbia'],
['bosniahercegovina','en_US','bs_BA','Bosnia-Hercegovina'],
['macedonia','en_US','mk_MK','Macedonia'],
['montenegro','en_US','sr_ME','Montenegro'],
    //['kosovo','en_US','en_US','Kosovo'], // does not exist in AEM?
['albania','en_US','sq_AL','Albania'],
['bulgaria','en_US','bg_BG','Bulgaria'],
['belarus','ru_RU','be_BY','Belarus'],
['newzealand','en_US','en_NZ','New Zealand'],
['kazakhstan','en_US','kk_RU','Kazakhstan'],
['georgia','en_US','ka_GE','Georgia'],
['armenia','en_US','hy_AM','Armenia'],
['azerbaijan','en_US','az_AZ','Azerbaijan']
];
 
var aemLocale=window.location.pathname.slice(1);
aemLocale=aemLocale.slice(0,aemLocale.indexOf('/'));
var AEMtoFW={
'en-us':'www.emc.com',//ok
'es-ar':'argentina.emc.com',//ok
'en-au':'australia.emc.com',//ok
'de-at':'austria.emc.com',//ok
'be-by':'belarus.emc.com',//ok
'fr-be':'belgium.emc.com',//ok
'pt-br':'brazil.emc.com',//ok
'en-ca':'canada.emc.com',//ok
'es-cl':'chile.emc.com',//ok
'zh-cn':'china.emc.com',//ok
'es-co':'colombia.emc.com',//ok
'cs-cz':'czech.emc.com',//ok
'da-dk':'denmark.emc.com',//ok
'et-ee':'estonia.emc.com',//ok
'fi-fi':'finland.emc.com',//ok
'fr-fr':'france.emc.com',//ok
'de-de':'germany.emc.com',//ok
'el-gr':'greece.emc.com',//ok
'en-hk':'hk.emc.com',//ok
'hu-hu':'hungary.emc.com',//ok
'hi-in':'india.emc.com',//ok
'id-id':'indonesia.emc.com',//ok
'en-ie':'ireland.emc.com',//ok
'he-il':'israel.emc.com',//ok
'it-it':'italy.emc.com',//ok
'ja-jp':'japan.emc.com',//ok
'ko-kr':'korea.emc.com',//ok
'lv-lv':'latvia.emc.com',//ok
'lb-lu':'lithuania.emc.com',//ok
'lt-lt':'luxembourg.emc.com',//ok
'ms-my':'malaysia.emc.com',//ok
'es-mx':'mexico.emc.com',//ok
'en-me':'middle-east.emc.com',//ok
'nl-nl':'netherlands.emc.com',//ok
'en-nz':'emc.com',//'newzealand.emc.com',//MISSING FROM FW/STORE LIST
'nb-no':'norway.emc.com',//ok
'es-pe':'peru.emc.com',//ok
'en-ph':'philippines.emc.com',//ok
'pl-pl':'poland.emc.com',//ok
'pt-pt':'portugal.emc.com',//ok
'es-pr':'puertorico.emc.com',//ok
'ru-ru':'russia.emc.com',//ok
'ar-sa':'saudi.emc.com',//ok
'en-sg':'singapore.emc.com',//ok
'en-za':'southafrica.emc.com',//ok
'es-es':'spain.emc.com',//ok
'fr-ch':'suisse.emc.com',//ok
'sv-se':'sweden.emc.com',//ok
'de-ch':'switzerland.emc.com',//ok
'zh-tw':'taiwan.emc.com',//ok
'th-th':'thailand.emc.com',//ok
'tr-tr':'turkey.emc.com',//ok
'en-gb':'uk.emc.com',//ok
'uk-ua':'ukraine.emc.com',//ok
'es-ve':'venezuela.emc.com',//ok
'vi-vn':'vietnam.emc.com',//ok
'sq-al':'albania.emc.com',//ok
'bs-ba':'bosnia-hercegovina.emc.com',//ok BUT MISSPELLED WITH C INSTEAD OF Z IN AEM LIST
'bg-bg':'bulgaria.emc.com',//ok
'mk-mk':'macedonia.emc.com',//ok
'sr-me':'montenegro.emc.com',//ok
'hr-hr':'croatia.emc.com',//ok
'sr-ba':'serbia.emc.com',//ok
'sl-sl':'slovenia.emc.com',//ok
'ro-ro':'romania.emc.com',//ok
'en-af':'africa.emc.com',//ok
'en-gm':'gambia.emc.com',//ok
'en-gh':'ghana.emc.com',//ok
'sw-ke':'kenya.emc.com',//ok
'en-lr':'liberia.emc.com',//ok
'en-ng':'nigeria.emc.com',//ok
'rw-rw':'rwanda.emc.com',//ok
'en-tz':'tanzania.emc.com',//ok
'en-ug':'uganda.emc.com',//ok
'en-zm':'zambia.emc.com',//ok
'kk-ru':'emc.com',//'kazakhstan.emc.com',//MISSING FROM FW/STORE LIST
'ka-ge':'emc.com',//'georgia.emc.com',//MISSING FROM FW/STORE LIST
'hy-am':'emc.com',//'armenia.emc.com',//MISSING FROM FW/STORE LIST
'az-az':'emc.com',//'azerbaijan.emc.com',//MISSING FROM FW/STORE LIST
'fr-af':'afrique.emc.com',//ok
'fr-cm':'cameroun.emc.com',//ok
'fr-ci':'cote-divoire.emc.com',//ok
'fr-ga':'gabon.emc.com',//ok
'fr-mg':'madagascar.emc.com',//ok
'fr-ma':'maroc.emc.com',//ok BUT MISSPELLED AS MOROCCO IN AEM LIST
'fr-sn':'senegal.emc.com',//ok
'en-see':'see.emc.com',//ok
'en-apj':'apj.em.com',//ok
'en-emea':'emea.em.com'//ok
};

// fallback -> D-16470
aemLocale = AEMtoFW.hasOwnProperty(aemLocale) ? aemLocale : 'en-us';

var fwDomain=AEMtoFW[aemLocale];


    // build full domain list from short list above
    //Old Code
/*
    for (var i=0;i<langMapNew.length;i++) {
         // prod live
         emcDomainMap[langMapNew[i][0]]=langMapNew[i][2];
         emcDomainMapP9[langMapNew[i][0]]=langMapNew[i][1];
         emcDomainDisplayNameMap[langMapNew[i][0]]=langMapNew[i][3];
         // preview and stage
         for (var e=0;e<envsWithoutSides.length;e++) {
              emcDomainMap[envsWithoutSides[e]+((langMapNew[i][0]=='www')?'':langMapNew[i][0])]=langMapNew[i][2];
              emcDomainMapP9[envsWithoutSides[e]+((langMapNew[i][0]=='www')?'':langMapNew[i][0])]=langMapNew[i][1];
              emcDomainDisplayNameMap[envsWithoutSides[e]+((langMapNew[i][0]=='www')?'':langMapNew[i][0])]=langMapNew[i][3];
         }
         for (var si=0;si<sides.length;si++) {
              for (var e=0;e<envsWithSides.length;e++) {
                   var temp=envsWithSides[e];
                   temp=temp.replace('[]',sides[si]);
                   emcDomainMap[temp+((langMapNew[i][0]=='www')?'':langMapNew[i][0])]=langMapNew[i][2];
                   emcDomainMapP9[temp+((langMapNew[i][0]=='www')?'':langMapNew[i][0])]=langMapNew[i][1];
                   emcDomainDisplayNameMap[temp+((langMapNew[i][0]=='www')?'':langMapNew[i][0])]=langMapNew[i][3];
              }
         }
    }


    // get subdomain for URL checks
    // this is stored as a global var because it's used/useful outside LP
    var subDomain=window.location.href.slice(window.location.href.indexOf('//')+2);
    if (subDomain.indexOf('/')>=0) { subDomain=subDomain.slice(0,subDomain.indexOf('/')); }
    if (subDomain.indexOf(':')>=0) { subDomain=subDomain.slice(0,subDomain.indexOf(':')); }
    if (subDomain.indexOf('.')>=0) { subDomain=subDomain.slice(0,subDomain.indexOf('.')); }
*/

//New code provided from Tom C for the new URL
// build full domain list from short list above
var emcDomainMapReverse={};
for (var i=0;i<langMapNew.length;i++) {
     // prod live
     emcDomainMap[langMapNew[i][0]]=langMapNew[i][2];
     emcDomainMapReverse[langMapNew[i][2]]=langMapNew[i][0];
     emcDomainMapP9[langMapNew[i][0]]=langMapNew[i][1];
     emcDomainDisplayNameMap[langMapNew[i][0]]=langMapNew[i][3];
     // preview and stage
     for (var e=0;e<envsWithoutSides.length;e++) {
          emcDomainMap[envsWithoutSides[e]+((langMapNew[i][0]=='www')?'':langMapNew[i][0])]=langMapNew[i][2];
          //emcDomainMapReverse[langMapNew[i][2]]=envsWithoutSides[e]+((langMapNew[i][0]=='www')?'':langMapNew[i][0]);
          emcDomainMapP9[envsWithoutSides[e]+((langMapNew[i][0]=='www')?'':langMapNew[i][0])]=langMapNew[i][1];
          emcDomainDisplayNameMap[envsWithoutSides[e]+((langMapNew[i][0]=='www')?'':langMapNew[i][0])]=langMapNew[i][3];
     }
     for (var si=0;si<sides.length;si++) {
          for (var e=0;e<envsWithSides.length;e++) {
               var temp=envsWithSides[e];
               temp=temp.replace('[]',sides[si]);
               emcDomainMap[temp+((langMapNew[i][0]=='www')?'':langMapNew[i][0])]=langMapNew[i][2];
               //emcDomainMapReverse[langMapNew[i][2]]=temp+((langMapNew[i][0]=='www')?'':langMapNew[i][0]);
               emcDomainMapP9[temp+((langMapNew[i][0]=='www')?'':langMapNew[i][0])]=langMapNew[i][1];
               emcDomainDisplayNameMap[temp+((langMapNew[i][0]=='www')?'':langMapNew[i][0])]=langMapNew[i][3];
          }
     }
}


// get subdomain for URL checks
// this is stored as a global var because it's used/useful outside LP
var subDomain='';

//get URL variables
// move from liveperson-country-and-page-list.js line 156 to be available on this file and the other (for loading sequences purpose)
var GETS={}; var hadGets=false; var sGet=window.location.search; if (sGet) { hadGets=true; processGETS(sGet); } function processGETS(sGet) { sGet=sGet.substr(1); var sNVPairs=sGet.split('&'); for (var i=0;i<sNVPairs.length;i++) { var sNV=sNVPairs[i].split('='); GETS[sNV[0]]=sNV[1]; } }

if (typeof(GETS['simulatedurl'])!='undefined') {
    subDomain=GETS['simulatedurl'];
} else {
	subDomain=window.location.href;
}
subDomain=subDomain.slice(subDomain.indexOf('//')+2);
if ($j('body').hasClass('uw') || (GETS['simulateaem']=='true' && typeof(GETS['simulatedurl'])!='undefined')) {
	// AEM
    //START Removing these 3 lines of code from Tom C instrucctions
	/*subDomain=subDomain.slice(subDomain.indexOf('/'));
	subDomain=subDomain.slice(1,3)+'_'+subDomain.slice(4,6).toUpperCase();
	subDomain=emcDomainMapReverse[subDomain]==undefined?'www':emcDomainMapReverse[subDomain];*/
    //END
        
    //Start This is the new code
        subDomain=fwDomain.slice(0,fwDomain.indexOf('.emc.com')); 
    //END
    
} else {
	// FW
	if (subDomain.indexOf('/')>=0) { subDomain=subDomain.slice(0,subDomain.indexOf('/')); }
	if (subDomain.indexOf(':')>=0) { subDomain=subDomain.slice(0,subDomain.indexOf(':')); }
	if (subDomain.indexOf('.')>=0) { subDomain=subDomain.slice(0,subDomain.indexOf('.')); }
}




    /* DISABLE/HIDE LOGIN AND GLOBAL SITE SELECTOR BUTTONS ON NON-EMC SITES.com (WEB.EMC.COM, ESTORE, etc.) */

    var gssAndSearchHidingSubDomains={

         // NOTE: DO NOT USE THESE SETTINGS UNLESS NECESSARY, PREFERRED METHOD IS TO HAVE REMOTE SITE SET ONE OF THE FOLLOWING CLASSES ON THE <body> TAG:
         // .remoteHideGSS, .remoteHideLogin, .remoteHideSearch, .remoteModifyLogin
         // IF REMOTE SITE DOES NOT ALLOW MODIFYING BODY TAG, USE JS TO APPLY THE CLASSES, EG: jQuery('body').addClass('remoteHideGSS');
         // IF THAT CAN'T BE DONE THEN ADD SUBDOMAIN TO THE LIST HERE

         // web.emc.com
         web: { 	hideGss: true, 	hideLogin: true, 	hideSearch: true,	modifyLoginLogout: false },

         // estore, including multiple dev and testing environments
         estore: {	hideGss: false,	hideLogin: false,	hideSearch: true,	modifyLoginLogout: true },
         estoredev: {	hideGss: false,	hideLogin: false,	hideSearch: true,	modifyLoginLogout: true },
         estoretst: {	hideGss: false,	hideLogin: false,	hideSearch: true,	modifyLoginLogout: true },
         estorestg: {	hideGss: false,	hideLogin: false,	hideSearch: true,	modifyLoginLogout: true },
         store: {	hideGss: false,	hideLogin: false,	hideSearch: true,	modifyLoginLogout: true },
         storedev: {	hideGss: false,	hideLogin: false,	hideSearch: true,	modifyLoginLogout: true },
         storetst: {	hideGss: false,	hideLogin: false,	hideSearch: true,	modifyLoginLogout: true },
         storestg: {	hideGss: false,	hideLogin: false,	hideSearch: true,	modifyLoginLogout: true },
         ebzappdev01: {	hideGss: false,	hideLogin: false,	hideSearch: true,	modifyLoginLogout: true },

         estoredevadmin: {	hideGss: false,	hideLogin: false,	hideSearch: true,	modifyLoginLogout: true },
         estoretstadmin: {	hideGss: false,	hideLogin: false,	hideSearch: true,	modifyLoginLogout: true },
         estorestgadmin: {	hideGss: false,	hideLogin: false,	hideSearch: true,	modifyLoginLogout: true },
         estoreadmin: {	hideGss: false,	hideLogin: false,	hideSearch: true,	modifyLoginLogout: true },

         // FOR TESTING ONLY:
         localhost:  {	hideGss: false,	hideLogin: false,	hideSearch: false,	modifyLoginLogout: true }

    };

    $j(window).load(function(){
         //trace('SUBDOMAIN USED FOR CHAT AND SHOW/HIDE GSS-SEARCH: '+subDomain);
         if (gssAndSearchHidingSubDomains[subDomain]!=undefined) {
              if (gssAndSearchHidingSubDomains[subDomain]['hideGss']) { $j('#siteSelectButton').css({ display: 'none' }); } // gss
              if (gssAndSearchHidingSubDomains[subDomain]['hideLogin']) { $j('#loginButton').css({ display: 'none' }); } // login
              if (gssAndSearchHidingSubDomains[subDomain]['hideSearch']) { $j('#searchFormWrapper').css({ display: 'none' }); } // search
         }
    });


/* >>> End of emc-domain-map.js */
/* <<< Start liveperson-country-and-page-list.js */

// DO NOT MODIFY THIS LINE-- Set up EMC LP Object and default settings 
if (typeof(emclp)=='undefined') { var emclp={}; }

/* BEGIN COUNTRY SETUP */
// only allow LP code to execute on desired subdomains (countries)
// set country code for use setting lang later, and set useLP to true so LP code gets run
// to enable it everywhere except prod live, set "isLive" to false
// then set "lang" as instructed by Harry Li

emclp.domainList={
    
    www: { isLive: true, useLP: true, isEstore: false, skill: 'english', translation: 'en_US', divisions: ['rsa','iig'] },
    
    canada: { isLive: true, useLP: true, isEstore: false, skill: 'english', translation: 'en_US', divisions: ['iig'] },
    uk: { isLive: true, useLP: true, isEstore: false, skill: 'uk-english', translation: 'en_US', divisions: [] },
    ireland: { isLive: true, useLP: true, isEstore: false, skill: 'uk-english', translation: 'en_US', divisions: [] },
    australia: { isLive: true, useLP: true, isEstore: false, skill: 'australia-english', translation: 'en_US', divisions: [] },
    newzealand: { isLive: true, useLP: true, isEstore: false, skill: 'australia-english', translation: 'en_US', divisions: [] },
    france: { isLive: true, useLP: true, isEstore: false, skill: 'france-french', translation: 'fr_FR', divisions: [] },
    germany: { isLive: true, useLP: true, isEstore: false, skill: 'germany-german', translation: 'de_DE', divisions: [] },
    middleeast: { isLive: true, useLP: true, isEstore: false, skill: 'uk-english', translation: 'en_US', divisions: [] },
    southafrica: { isLive: true, useLP: true, isEstore: false, skill: 'southafrica-english', translation: 'en_US', divisions: [] },
    singapore: { isLive: true, useLP: true, isEstore: false, skill: 'singapore-english', translation: 'en_US', divisions: [] },
    india: { isLive: true, useLP: true, isEstore: false, skill: 'india-english', translation: 'en_US', divisions: [] },
    italy: { isLive: true, useLP: true, isEstore: false, skill: 'italy-italian', translation: 'it_IT', divisions: [] },
    china: { isLive: true, useLP: true, isEstore: false, skill: 'china-chinese', translation: 'zh_CN', divisions: [] },
    brazil: { isLive: true, useLP: true, isEstore: false, skill: 'brazil-portuguese', translation: 'pt_BR', divisions: [] },
    mexico: { isLive: true, useLP: true, isEstore: false, skill: 'mexico-spanish', translation: 'es_MX', divisions: [] },
    spain: { isLive: true, useLP: true, isEstore: false, skill: 'spain-spanish', translation: 'es_ES', divisions: [] },
    portugal: { isLive: true, useLP: true, isEstore: false, skill: 'portugal-portuguese', translation: 'pt_PT', divisions: [] },
    austria: { isLive: true, useLP: true, isEstore: false, skill: 'germany-german', translation: 'de_DE', divisions: [] },
    switzerland: { isLive: true, useLP: true, isEstore: false, skill: 'germany-german', translation: 'de_DE', divisions: [] },
    suisse: { isLive: true, useLP: true, isEstore: false, skill: 'france-french', translation: 'fr_FR', divisions: [] },
    netherlands: { isLive: true, useLP: true, isEstore: false, skill: 'uk-english', translation: 'en_US', divisions: [] },
    belgium: { isLive: true, useLP: true, isEstore: false, skill: 'uk-english', translation: 'en_US', divisions: [] },
    sweden: { isLive: true, useLP: true, isEstore: false, skill: 'uk-english', translation: 'en_US', divisions: [] },
    poland: { isLive: true, useLP: true, isEstore: false, skill: 'poland-polish', translation: 'pl_PL', divisions: [] },
    argentina: { isLive: true, useLP: true, isEstore: false, skill: 'mexico-spanish', translation: 'es_MX', divisions: [] },
    chile: { isLive: true, useLP: true, isEstore: false, skill: 'mexico-spanish', translation: 'es_MX', divisions: [] },
    colombia: { isLive: true, useLP: true, isEstore: false, skill: 'mexico-spanish', translation: 'es_MX', divisions: [] },
    peru: { isLive: true, useLP: true, isEstore: false, skill: 'mexico-spanish', translation: 'es_MX', divisions: [] },
    puertorico: { isLive: true, useLP: true, isEstore: false, skill: 'mexico-spanish', translation: 'es_MX', divisions: [] },
    venezuela: { isLive: true, useLP: true, isEstore: false, skill: 'mexico-spanish', translation: 'es_MX', divisions: [] },
    russia: { isLive: true, useLP: true, isEstore: false, skill: 'russia-russian', translation: 'ru_RU', divisions: [] },
    afrique: { isLive: true, useLP: true, isEstore: false, skill: 'france-french', translation: 'fr_FR', divisions: [] },
    czech: { isLive: true, useLP: true, isEstore: false, skill: 'czech-czech', translation: 'cs_CZ', divisions: [] },
    turkey: { isLive: true, useLP: true, isEstore: false, skill: 'turkey-turkish', translation: 'tr_TR', divisions: [] },
    africa: { isLive: true, useLP: true, isEstore: false, skill: 'uk-english', translation: 'en_US', divisions: [] },
    saudi: { isLive: true, useLP: true, isEstore: false, skill: 'uk-english', translation: 'en_US', divisions: [] },
    see: { isLive: true, useLP: true, isEstore: false, skill: 'uk-english', translation: 'en_US', divisions: [] },

    japan: { isLive: true, useLP: true, isEstore: false, skill: 'japan-japanese', translation: 'ja_JP', divisions: [] },
    //korea: { isLive: true, useLP: true, isEstore: false, skill: 'korea-korean', translation: 'ko_KR', divisions: [] },

    // ecn
    community: { isLive: true, useLP: true, isEstore: false, skill: 'english', translation: 'en_US', divisions: [] },
    ecndev: { isLive: false, useLP: true, isEstore: false, skill: 'english', translation: 'en_US', divisions: [] },
    ecnstaging: { isLive: false, useLP: true, isEstore: false, skill: 'english', translation: 'en_US', divisions: [] },
    
    // estore
    estoredevadmin: { isLive: false, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    estoretstadmin: { isLive: false, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    estorestgadmin: { isLive: false, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    estoreadmin: { isLive: true, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    estorestg: { isLive: false, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    estoretst: { isLive: false, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    estoredev: { isLive: false, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    estore: { isLive: true, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    storestg: { isLive: false, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    storetst: { isLive: false, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    storedev: { isLive: false, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    store: { isLive: true, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    ebzappdev01: { isLive: false, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    ebzappdev02: { isLive: false, useLP: true, isEstore: true, skill: 'store-english', translation: 'en_US', divisions: [] },
    
    test: { isLive: false, useLP: true, isEstore: false, skill: 'english', translation: 'en_US', divisions: ['iig','rsa'] },
    emc2: { isLive: false, useLP: true, isEstore: false, skill: 'english', translation: 'en_US', divisions: ['iig','rsa'] },
    
    'default': { isLive: false, useLP: false, isEstore: false, skill: 'english', translation: 'en_US', divisions: ['iig','rsa'] }

};

// list of URL patterns for determining division and pro/re state
emclp.livePersonDirectoryList={ 
    divisions: {
        iig: [
            // iig division pages URL patterns
            '/case-management/',
            '/content-management/',
            '/enterprise-content-management/',
            // iig testing
            '/iig-test'
        ],
        rsa: [
            // rsa division pages URL patterns
            '/security/',
            '/support/rsa/',
            // rsa testing
            '/rsa-test',
	    '/rsa/',
	    '/rsa-'
        ]
    },
    proactive: [
        // directories forced to Proactive chat
        '/cloud/hybrid-cloud-computing/',
        '/storage/',
        '/backup-and-recovery/',
        '/cloud-virtualization/',
        '/big-data/',
        '/security/',
        '/enterprise-content-management/',
        '/data-center-management/',
        // industries URL patterns
        '/industry/',
        '/solutions/industry/',
        // platforms URL patterns
        '/platform/',
        '/storage/',
        // testing
        '/pro-test'
    ],
    reactive: [
        // directories forced to Reactive chat
        '/campaign/',
        '/campaigns/',
	'/security/',
	'/support/rsa/',
	'/rsa/',
	'/rsa-'
    ]
};



///////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////// END EDITABLE URL PATTERNS AND COUNTRY LISTS ///////////////////////////////////////////
/////////////////// DO NOT EDIT PAST THIS POINT! //////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////


// big int/base conversion support
var bigNum={add:function(x,y,base){var z=[];var n=Math.max(x.length,y.length);var carry=0;var i=0;while(i<n||carry){var xi=i<x.length?x[i]:0;var yi=i<y.length?y[i]:0;var zi=carry+xi+yi;z.push(zi%base);carry=Math.floor(zi/base);i++;}
return z;},multiplyByNumber:function(num,x,base){if(num<0)return null;if(num==0)return[];var result=[];var power=x;while(true){if(num&1){result=bigNum.add(result,power,base);}
num=num>>1;if(num===0)break;power=bigNum.add(power,power,base);}
return result;},parseToDigitsArray:function(str,base){var digits=str.split('');var ary=[];for(var i=digits.length-1;i>=0;i--){var n=parseInt(digits[i],base);if(isNaN(n))return null;ary.push(n);}
return ary;},convertBase:function(str,fromBase,toBase){var digits=bigNum.parseToDigitsArray(str,fromBase);if(digits===null)return null;var outArray=[];var power=[1];for(var i=0;i<digits.length;i++){if(digits[i]){outArray=bigNum.add(outArray,bigNum.multiplyByNumber(digits[i],power,toBase),toBase);}
power=bigNum.multiplyByNumber(fromBase,power,toBase);}
var out='';for(var i=outArray.length-1;i>=0;i--){out+=outArray[i].toString(toBase);}
return out;},decToHex:function(decStr){var hex=bigNum.convertBase(decStr,10,16);return hex?'0x'+hex:null;},hexToDec:function(hexStr){if(hexStr.substring(0,2)==='0x')hexStr=hexStr.substring(2);hexStr=hexStr.toLowerCase();return bigNum.convertBase(hexStr,16,10);}};


//get URL variables // moved to emc-domain-map.js line 182 to be available on both files and the other (for loading sequences purpose)

// vars for legacy support
var livePersonSkill; var livePersonLanguage; var useLP=false;

emclp.useLP=false;
emclp.livePersonLanguage='english';
emclp.simulatedURL=false;
emclp.livePersonIsEstore=false;
emclp.livePersonDebugOutput='Debug output from LivePerson Config:'; // will be added to later


/*
//Old code that needs to be changed for the new URL
if (typeof(GETS['simulatedurl'])!='undefined') {
    emclp.simulatedURL=GETS['simulatedurl'];
    subDomain=emclp.simulatedURL.slice(emclp.simulatedURL.indexOf('//')+2).split('.emc.com').join('').split('.emc.dev').join('').split('.sequelcommunications.com').join('');
} else {
    subDomain=window.location.hostname.split('.emc.com').join('').split('.emc.dev').join('').split('.sequelcommunications.com').join('');
}
subDomain=subDomain.split('-').join('');

if (subDomain.indexOf('/')>=0) { subDomain=subDomain.slice(0,subDomain.indexOf('/')); }
if (subDomain.indexOf(':')>=0) { subDomain=subDomain.slice(0,subDomain.indexOf(':')); }
if (subDomain.indexOf('.')>=0) { subDomain=subDomain.slice(0,subDomain.indexOf('.')); }
*/
//New code provided from Tom C

if (typeof(GETS['simulatedurl'])!='undefined') {
    emclp.simulatedURL=GETS['simulatedurl'];
}



emclp.livePersonDebugOutput+='\nSubdomain: '+subDomain;
emclp.livePersonSkill='emc-sales-english';

emclp.checkForOverrides=function(valName,val) {
    // check for presence of emclpoverrides variable in the page and the presence of a value for the setting we're looking for, and return it if found, otherwise return initial value
    if (typeof(emclp.overrides)!='undefined') {
        if (typeof(emclp.overrides[valName])!='undefined') {
            return emclp.overrides[valName];
        } else {
            return val;
        }
    } else if ($j('.chat-override').length>0) {
	var temp='notsetyet';
	$j('.chat-override').each(function(ix,el) {
	    if ($j(el).attr('data-parameter')==valName) {
		temp=$j(el).attr('data-value');
	    }
	});
	if (temp!='notsetyet') {
	    return temp;
	} else {
	    return val;
	}
    } else {
        return val;
    }
};

emclp.overridesInUse=function() {
    if (typeof(emclp.overrides)!='undefined') {
        var temp='';
        for (var i in emclp.overrides) {
            temp+=i+':'+emclp.overrides[i]+', ';
        }
        return temp.slice(0,-2);
    } else {
        return 'none';
    }
};

emclp.getChatType=function() {
    var ct='RE'; // default
    // check directory list for initial setting
    for (var i in emclp.livePersonDirectoryList.proactive) {
        if (emclp.livePersonPageURL.indexOf(emclp.livePersonDirectoryList.proactive[i])==0) {
            ct='PRO';
        }
    }
    for (var i in emclp.livePersonDirectoryList.reactive) {
        if (emclp.livePersonPageURL.indexOf(emclp.livePersonDirectoryList.reactive[i])==0) {
            ct='RE';
        }
    }
    // check for variables set in the page to override this
    ct=emclp.checkForOverrides('chatType',ct);
    // check for adwords-enabled location and return RE for those, return either default or the override value from previous step for others
    return ct;
};

emclp.getDivision=function() {
    var dv='emc';
    // get division from lists if this is still needed
    for (var i in emclp.livePersonDirectoryList.divisions) {
        for (var k in emclp.livePersonDirectoryList.divisions[i]) {
            if (emclp.livePersonPageURL.indexOf(emclp.livePersonDirectoryList.divisions[i][k])>=0) {
                dv=i;
            }
        }
    }
    // check for variables set in the page to override this
    dv=emclp.checkForOverrides('division',dv);
    emclp.division=dv;
    return dv;
};

emclp.getDivisionForInsertion=function(dashBefore) {
    return ((emclp.getDivision()=='emc')?'':(dashBefore?'-':'')+emclp.getDivision()+(dashBefore?'':'-'));
};


emclp.getChatTypeValueFromString=function(inStr) {
    switch (inStr) {
        case 'OFF' : return 0;
        case 'RE' : return 2;
        default : return 1;
    }
};

emclp.getDomainValues=function(inSubDomain) {
    var tempVals=emclp.domainList['default'];
    var isLiveServer=false;
    
    inSubDomain=inSubDomain.split('-').join('').split('.').join('').toLowerCase();
    
    // if subdomain is found in list without modifiction, this is a live site and we should use
    // the value stored in "isLive" for "useLP". Otherwise we're not live and we should use the value in "useLP"
    
    if (typeof(emclp.domainList[inSubDomain])!='undefined') {
	tempVals=emclp.domainList[inSubDomain];
	isLiveServer=tempVals.isLive;
    } else {
	var temp=inSubDomain;
	for (var e=0;e<envsWithoutSides.length;e++) {
	    temp=temp.replace(envsWithoutSides[e],'');
	}
	for (var e=0;e<envsWithSides.length;e++) {
	    for (var si=0;si<sides.length;si++) {
		var thisDomain=envsWithSides[e].split('[]').join(sides[si]);
		temp=temp.replace(thisDomain,'');
	    }
	}
	if (temp.length<2) {
	    temp='www'; // we're on a US site
	}
	var tempVals2=emclp.domainList[temp];
	if (typeof(tempVals2)!='undefined') {
	    tempVals=tempVals2;
	}
	isLiveServer=false;
    }
    
    if (!emclp.simulatedURL && window.location.hostname.indexOf('.dev')>=0) {
	isLiveServer=false;
    }
    
    // set LP account info based on server
    if (!isLiveServer) {
	// dev account
	//emclp.lpserver='dev.liveperson.net';
	//emclp.lpnumber='P5047164';
	//emclp.appkey='0a259e5db07b459bb67b993a02c4d59e';
	//emclp.livePersonDebugOutput+='\nLP Account: Dev (';
	// emc clone account
	emclp.lpserver='sales.liveperson.net';
	emclp.lpnumber='60189845';
	emclp.appkey='13bcdcd2c24143ceb011aea0a24487e8';
	emclp.livePersonDebugOutput+='\nLP Account: Clone (';
    } else {
	// emc live account
	emclp.lpserver='sales.liveperson.net';
	emclp.lpnumber='67761027';
	emclp.appkey='2483dffc679545b28cc525577e26772f';
	emclp.livePersonDebugOutput+='\nLP Account: Live (';
    }
    
    // do not edit this last part
    return {
	useLP: isLiveServer?tempVals.isLive:tempVals.useLP,
	livePersonLanguage: tempVals.skill,
	livePersonIsEstore: tempVals.isEstore,
        translation: tempVals.translation,
	divisions: tempVals.divisions
    };

};

// get page URL from root of site
if (emclp.simulatedURL) {
    var temp=emclp.simulatedURL.replace('http://','').replace('https://','');
    emclp.livePersonPageURL=temp;
    emclp.livePersonHostname=temp.slice(0,temp.indexOf('/'));
} else {    
    emclp.livePersonPageURL=window.location.href.replace('http://','').replace('https://','');
    emclp.livePersonHostname=window.location.hostname;
}

emclp.livePersonPageURL=emclp.livePersonPageURL.slice(emclp.livePersonPageURL.indexOf('/'));
if (emclp.livePersonPageURL.indexOf('?')>=0) {
    emclp.livePersonPageURL=emclp.livePersonPageURL.slice(0,emclp.livePersonPageURL.indexOf('?'));
}
if (emclp.livePersonPageURL.indexOf('#')>=0) {
    emclp.livePersonPageURL=emclp.livePersonPageURL.slice(0,emclp.livePersonPageURL.indexOf('#'));
}


emclp.pageValues=emclp.getDomainValues(subDomain);

emclp.livePersonDebugOutput+=emclp.lpnumber+') '+emclp.lpserver;

emclp.useLP=useLP=emclp.pageValues.useLP;
emclp.livePersonLanguage=livePersonLanguage=emclp.pageValues.livePersonLanguage;
emclp.livePersonLanguage=emclp.checkForOverrides('language',emclp.livePersonLanguage);
emclp.livePersonSkill=livePersonSkill='emc-sales-'+emclp.pageValues.livePersonLanguage;
emclp.livePersonIsEstore=livePersonIsEstore=emclp.pageValues.livePersonIsEstore;
emclp.livePersonTranslation=emclp.pageValues.translation;

emclp.livePersonPageList=[]; // empty now that all pages are enabled, still here just in case something references it

emclp.copyObj=function(inObj) {
    outObj={};
    for (o in inObj) {
         outObj[o]=inObj[o];
    }
    return outObj;
};

emclp.readCookie=function(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for (var i=0;i < ca.length;i++) {
	var c = ca[i];
	while (c.charAt(0)==' ') c = c.substring(1,c.length);
	if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
};
emclp.createCookie=function(name,value,days) {
	//console.log('create cookie '+name+' '+value+' '+days);
	var expires='';
	if (days!=undefined) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		expires = '';//"; expires="+date.toGMTString();
	}
	document.cookie = name+"="+value+expires+"; path=/";
};
emclp.eraseCookie=function(name) {
     createCookie(name,"",-1);
};

// add Array.indexOf method to IE<=8
if(!Array.prototype.indexOf){Array.prototype.indexOf=function(searchElement){"use strict";if(this==null){throw new TypeError();} var t=Object(this);var len=t.length>>>0;if(len===0){return-1;} var n=0;if(arguments.length>0){n=Number(arguments[1]);if(n!=n){n=0;}else if(n!=0&&n!=Infinity&&n!=-Infinity){n=(n>0||-1)*Math.floor(Math.abs(n));}} if(n>=len){return-1;} var k=n>=0?n:Math.max(len-Math.abs(n),0);for(;k<len;k++){if(k in t&&t[k]===searchElement){return k;}} return-1;}}




function livePersonAlertDebugOutput() {
    alert(emclp.livePersonDebugOutput+'\n________________________________________________________');
}

emclp.livePersonFinishSetup=function() {

    // move eStore variables for backwards-compatibility
    emclp.livePersonIsEstore=(typeof(livePersonIsEstore)=='undefined')?false:livePersonIsEstore;
    emclp.eStoreChat=(typeof(eStoreChat)=='undefined')?false:eStoreChat;

    // debug output
    emclp.livePersonDebugOutput+='\nLanguage:  '+emclp.livePersonLanguage;
    emclp.livePersonDebugOutput+='\nPage URL:  '+emclp.livePersonHostname+emclp.livePersonPageURL + (emclp.simulatedURL?' (SIMULATED URL)':'');
    emclp.livePersonDebugOutput+='\nPage-specific overrides in use: '+emclp.overridesInUse();
 
    lpMTagConfig.lpServer = emclp.lpserver;
    lpMTagConfig.lpNumber = emclp.lpnumber;

    lpMTagConfig.lpTagSrv = lpMTagConfig.lpServer;
    lpMTagConfig.deploymentID = "emc-sales";
    
    lpMTagConfig.vars.push(["page","unit","emc-sales"]);
    lpMTagConfig.vars.push(["session","pageurl",emclp.livePersonHostname+emclp.livePersonPageURL.split('http://').join('').split('https://').join('')]);
    
    //emclp.createCookie('s_vi','[CS]v1|29B0962D051D1D05-6000013720000048[CE]',-1);
    // tracking pass-through
    if (emclp.readCookie('s_vi')!=null) {
	var temp=emclp.readCookie('s_vi');
	temp=temp.slice(7,-4);
	temp=temp.split('-');
	if (temp.length==2) {
            temp=bigNum.convertBase(temp[0],16,10)+'_'+bigNum.convertBase(temp[1],16,10);
	    lpMTagConfig.vars.push(['session','OmnitureVisitorID',temp]);
	}
    }
    if (emclp.readCookie('emc_MUP_ID_persist')!=null) {
	lpMTagConfig.vars.push(['session','MupID',emclp.readCookie('emc_MUP_ID_persist')]);
    }
    if (GETS['am_id']!=undefined) {
	lpMTagConfig.vars.push(['session','AudienceMemID',GETS['am_id']]);
    } else if (emclp.readCookie('emc_AM_ID_persist')!=null) {
	lpMTagConfig.vars.push(['session','AudienceMemID',emclp.readCookie('emc_AM_ID_persist')]);
    }
        
    // override language and unit variables for some implementations, add custom variables to others
    if (emclp.getDivision()!='emc') {
     
	// SPECIAL CASES
	// force all skills containing "english" in the name to the main "english" iig skill group by resetting the language value
	if (emclp.livePersonLanguage.indexOf('english')>=0) {
	    emclp.livePersonLanguage='english';
	}

        if (emclp.pageValues.divisions.indexOf(emclp.getDivision())<0) {
            emclp.livePersonDebugOutput+='\n'+emclp.getDivision().toUpperCase()+' division in unsupported language, removing chat';
            $j(document).ready(function() { $j('.inboundBar .ib-icon-sales-chat').remove(); });
        }
        
    } else if (emclp.livePersonIsEstore) {
    
	if (typeof(storeSessionId)!='undefined') {
	    lpMTagConfig.vars.push(["session","SessionID",storeSessionId]);
	}
        
    }

    lpMTagConfig.vars.push(["session","language",emclp.getDivisionForInsertion()+emclp.livePersonLanguage]);
    emclp.livePersonSkill='emc-sales-'+emclp.getDivisionForInsertion()+emclp.livePersonLanguage;
    
    lpMTagConfig.vars.push(["page","PageName",document.title]);
    lpMTagConfig.vars.push(["page","Section",emclp.livePersonPageURL.split('http://').join('').split('https://').join('').split('/')[1]]);

    // custom variable ChatEnabled -- determines whether the page gets the button, the button and proactive chat prompt, or nothing
 
    if (typeof(eStoreChat)=='undefined') {
       emclp.eStoreChat='OFF';
    }

    if (emclp.livePersonIsEstore) {
        
        lpMTagConfig.vars.push(["page","ChatEngage",emclp.getChatTypeValueFromString(emclp.eStoreChat)]);
        
    } else {
        
        lpMTagConfig.vars.push(["page","ChatEngage",emclp.getChatTypeValueFromString(emclp.getChatType())]);
            
        // debug output
        emclp.livePersonDebugOutput+='\nButton HTML is in the page?:  '+($j('#lpChatButton').length>0);

        // fix for missing lpChatButton on pages with share bars from HTML not include:
        if (emclp.getChatTypeValueFromString(emclp.getChatType()) && $j('#lpChatButton').length==0) {
            // debug output
            emclp.livePersonDebugOutput+='\n   --> Trying to add button HTML dynamically...';
             if ($j('.utility-item').length==0) {
               // debug output
               emclp.livePersonDebugOutput+='\n   --> No suitable location for button HTML!';
             } else {
               // debug output
               emclp.livePersonDebugOutput+='\n   --> Added button HTML to utility bar successfully!';
               $j('.utility-item').eq(0).before('<li class="utility-item"><div id="lpChatButton" style="margin: 5px 0px 0px 5px;"></div></li>');
            }
        }

        // if all else fails, add hidden lpChatButton <div> for simulated click functionality
        // also set up simultated click links (also used by Inbound Bar)
        //$j(document).ready(emclp.setupSimulatedClicks);
        // set up again at window.load in case pages are showing them on doc.ready
        $j(window).load(emclp.setupSimulatedClicks);
        
    }
     
    // debug output    
    if (!emclp.livePersonIsEstore) {
        emclp.livePersonDebugOutput+='\nChat setting:  '+emclp.getChatType();
        emclp.livePersonDebugOutput+='\nVariables being sent to LivePerson:';
        for (v in lpMTagConfig.vars) {
           if (lpMTagConfig.vars[v][1]!='undefined' && lpMTagConfig.vars[v][1]!=undefined) {
                emclp.livePersonDebugOutput+='\n   --> '+lpMTagConfig.vars[v][1]+':  '+lpMTagConfig.vars[v][2];
           }
        }
   } else {
        emclp.livePersonDebugOutput+='\nChat setting:  '+emclp.eStoreChat;
        emclp.livePersonDebugOutput+='\nVariables being sent to LivePerson:';
        for (v in lpMTagConfig.vars) {
           if (lpMTagConfig.vars[v][1]!='undefined' && lpMTagConfig.vars[v][1]!=undefined) {
                emclp.livePersonDebugOutput+='\n   --> '+lpMTagConfig.vars[v][1]+':  '+lpMTagConfig.vars[v][2];
           }
        }
    }
    emclp.livePersonDebugOutput+='\nDivision:  '+emclp.division;
    emclp.livePersonDebugOutput+='\nPage is in eStore?:  '+emclp.livePersonIsEstore;
     
    trace('================================================');
    trace(emclp.livePersonDebugOutput);
    trace('================================================');
 
    // for legacy support in case existing uses check old chat system activation
    livePersonSkill=emclp.livePersonSkill;

};

emclp.setupSimulatedClicks=function() {
    if (emclp.getChatTypeValueFromString(emclp.getChatType()) && $j('#lpChatButton').length==0) {
        $j('body').append('<div style="width: 0px; height: 0px; overflow: hidden;"><div id="lpChatButton" class="emclp-simulated-click-target"></div></div>');
        emclp.livePersonDebugOutput+='\nNo button present: adding hidden lpChatButton for simulated click support!';
    }
    $j('.emclp-simulate-click').each(function(ix,el) {
        if (!$j(el).hasClass('emclp-setup')) {
            $j(el).click(function(ev) {
                $j('#lpChatButton a img').first().click();
                ev.preventDefault();
            });
	    $j(el).closest('.emclp-simulate-click').addClass('emclp-setup');
        }
    });
};

emclp.livePersonNotEnabled=function() {
     // debug output
     emclp.livePersonDebugOutput+='\nLanguage:  '+emclp.livePersonLanguage;
     emclp.livePersonDebugOutput+='\nPage URL:  '+emclp.livePersonPageURL;
     emclp.livePersonDebugOutput+='\nLIVEPERSON NOT ENABLED FOR THIS COUNTRY';
    
     trace('================================================');
     trace(emclp.livePersonDebugOutput);
     trace('================================================');
};



if (emclp.useLP) {

if ($j('#lpChatButton').length==0) {
    // force button add at top of page if none is present in the HTML so far
    $j('body').prepend('<div style="width: 0px; height: 0px; overflow: hidden;"><div id="lpChatButton" class="emclp-simulated-click-target"></div></div>');
}

/* LIVE PERSON PROVIDED CODE BELOW, FOR UPDATES COPY AND PASTE OVER THE CODE BETWEEN THESE COMMENTS, DO NOT DISTURB CODE ABOVE OR BELOW COMMENTS */
var lpMTagConfig=lpMTagConfig||{};lpMTagConfig.vars=lpMTagConfig.vars||[];lpMTagConfig.dynButton=lpMTagConfig.dynButton||[];lpMTagConfig.lpProtocol=document.location.toString().indexOf("https:")==0?"https":"http";lpMTagConfig.pageStartTime=(new Date).getTime();if(!lpMTagConfig.pluginsLoaded)lpMTagConfig.pluginsLoaded=!1;
lpMTagConfig.loadTag=function(){for(var a=document.cookie.split(";"),b={},c=0;c<a.length;c++){var d=a[c].substring(0,a[c].indexOf("="));b[d.replace(/^\s+|\s+$/g,"")]=a[c].substring(a[c].indexOf("=")+1)}for(var a=b.HumanClickRedirectOrgSite,b=b.HumanClickRedirectDestSite,c=["lpTagSrv","lpServer","lpNumber","deploymentID"],d=!0,e=0;e<c.length;e++)lpMTagConfig[c[e]]||(d=!1,typeof console!="undefined"&&console.log&&console.log("LivePerson : lpMTagConfig."+c[e]+" is required and has not been defined before lpMTagConfig.loadTag()."));
if(!lpMTagConfig.pluginsLoaded&&d)lpMTagConfig.pageLoadTime=(new Date).getTime()-lpMTagConfig.pageStartTime,a="?site="+(a==lpMTagConfig.lpNumber?b:lpMTagConfig.lpNumber)+"&d_id="+lpMTagConfig.deploymentID+"&default=simpleDeploy",lpAddMonitorTag(lpMTagConfig.deploymentConfigPath!=null?lpMTagConfig.lpProtocol+"://"+lpMTagConfig.deploymentConfigPath+a:lpMTagConfig.lpProtocol+"://"+lpMTagConfig.lpTagSrv+"/visitor/addons/deploy2.asp"+a),lpMTagConfig.pluginsLoaded=!0};
function lpAddMonitorTag(a){if(!lpMTagConfig.lpTagLoaded){if(typeof a=="undefined"||typeof a=="object")a=lpMTagConfig.lpMTagSrc?lpMTagConfig.lpMTagSrc:lpMTagConfig.lpTagSrv?lpMTagConfig.lpProtocol+"://"+lpMTagConfig.lpTagSrv+"/hcp/html/mTag.js":"/hcp/html/mTag.js";a.indexOf("http")!=0?a=lpMTagConfig.lpProtocol+"://"+lpMTagConfig.lpServer+a+"?site="+lpMTagConfig.lpNumber:a.indexOf("site=")<0&&(a+=a.indexOf("?")<0?"?":"&",a=a+"site="+lpMTagConfig.lpNumber);var b=document.createElement("script");b.setAttribute("type",
"text/javascript");b.setAttribute("charset","iso-8859-1");b.setAttribute("src",a);document.getElementsByTagName("head").item(0).appendChild(b)}}window.attachEvent?window.attachEvent("onload",function(){lpMTagConfig.disableOnLoad||lpMTagConfig.loadTag()}):window.addEventListener("load",function(){lpMTagConfig.disableOnLoad||lpMTagConfig.loadTag()},!1);
function lpSendData(a,b,c){if(arguments.length>0)lpMTagConfig.vars=lpMTagConfig.vars||[],lpMTagConfig.vars.push([a,b,c]);if(typeof lpMTag!="undefined"&&typeof lpMTagConfig.pluginCode!="undefined"&&typeof lpMTagConfig.pluginCode.simpleDeploy!="undefined"){var d=lpMTagConfig.pluginCode.simpleDeploy.processVars();lpMTag.lpSendData(d,!0)}}function lpAddVars(a,b,c){lpMTagConfig.vars=lpMTagConfig.vars||[];lpMTagConfig.vars.push([a,b,c])};
/* LIVE PERSON PROVIDED CODE ABOVE, FOR UPDATES COPY AND PASTE OVER THE CODE BETWEEN THESE COMMENTS, DO NOT DISTURB CODE ABOVE OR BELOW COMMENTS */
        
emclp.livePersonFinishSetup();

} else {
     
emclp.livePersonNotEnabled();
     
}

/* >>> End of liveperson-country-and-page-list.js */
/*
 Text2Container v0.1 - jQuery Plugin
 (c) 2015 Javier Valderrama
 Increment/decrement font size to fit container's 100% width
 
 Usage:
 jQuery('.your-selector').fitMe2({options}); // options as on default object
 or
 jQuery('.your-selector').fitMe2(); // options from data-fitme2-* attributes
 <span class="your-selector" data-fitme2-line-height="100%" data-fitme2-initial-delay="100" data-fitme2-initial-delay="100" >my text</span>
 or
 jQuery('.your-selector').fitMe2(); //use default options
 
 List of dat-* API options 

fittingClass                    -> data-fitme2-fitting-class="myCustomFittingClass" //string
whatchForContentChange          -> data-fitme2-whatch-for-content-change="1" // 1|0
whatchStopAfterContentChange    -> data-fitme2-whatch-stop-after-content-change="1" // 1|0
initialDelay                    -> data-fitme2-initial-delay="100"  // miliseconds
debounceTime                    -> data-fitme2-debounce-time="50" // miliseconds
maxFontSize                     -> data-fitme2-max-font-size="300" //number, resolves to pixels unit
lineHeight                      -> data-fitme2-line-height="0.85em" // any unit
webfontListenerSelector         -> data-fitme2-webfont-listener-selector="" // selector string or element object
webfontListenerEvent            -> data-fitme2-webfont-listener-event="" // event name string
 */

(function ($, window, document, UW, undefined) {
    'use strict';

    $.widget("UW.fitMe2", {
        cache: {},
        defaults: {
            fittingClass: "fitMe2-fitting",
            whatchForContentChange: 0,
            whatchStopAfterContentChange: 0,
            initialDelay: 100,
            debounceTime: 50,
            maxFontSize: Number.POSITIVE_INFINITY,
            lineHeight: '0.85em',
            webfontListenerSelector: null, // e.g. window
            webfontListenerEvent: null // e.g. 'typekit.fonts.ready'
        },
        options: {},
        /**
         * 
         * @returns {undefined}
         */
        _create: function () {

            this._setOptionsFromData(this.defaults, this.options, this.element.data()).then($.proxy(function () {

                return this._webfontListener();

            }, this)).then($.proxy(function () {

                return this._initialDelay();

            }, this)).then($.proxy(function () {

                return this._setup();

            }, this)).then($.proxy(function () {

                return this._fitText();

            }, this)).then($.proxy(function () {

                return this._addBindings();

            }, this)).then($.proxy(function () {

                return this._whatchForContentChange();

            }, this));

        },
        /**
         * 
         * @param {object} defaults default options
         * @param {object} pluginOptions options passed by javascript
         * @param {object} elementData options passed by element data-fitMe2-* attributes
         * @returns {Object}
         */
        _setOptionsFromData: function (defaults, pluginOptions, elementData) {

            var deferred = new $.Deferred(),
                declaredOptions = {},
                optionName,
                val,
                p;

            function lowerCase(s) {
                return (s || '').toLowerCase();
            }

            for (p in elementData) {

                if (elementData.hasOwnProperty(p) && /^fitme2[A-Z]+/.test(p)) {
                    val = elementData[p];
                    optionName = p.match(/^fitme2(.*)/)[1].replace(/^[A-Z]/, lowerCase);
                    declaredOptions[optionName] = val;
                }
            }

            this.options = $.extend({}, defaults, declaredOptions, pluginOptions || {});

            deferred.resolve();

            return deferred.promise();
        },
        /**
         * 
         * @returns {object} $.Deferred().promise()
         */
        _initialDelay: function () {
            var deferred = new $.Deferred();

            setTimeout(function () {

                deferred.resolve();

            }, this.options.initialDelay);

            return deferred.promise();
        },
        /**
         * 
         * @returns {object} $.Deferred().promise()
         */
        _webfontListener: function () {
            var deferred = new $.Deferred(),
                resolved = false;

            
            if (!Modernizr.appleios && this.options.webfontListenerSelector && this.options.webfontListenerEvent) {
                
                // wait for event before move on
                $(this.options.webfontListenerSelector).on(this.options.webfontListenerEvent, function () {
                    !resolved && deferred.resolve();
                    resolved = true;
                });
                
                setTimeout(function(){
                    
                    if (!resolved){
                    deferred.resolve();
                        resolved = true;
                    }
                    
                },5000);
                
            } else {
                // no event listener, so move on
                !resolved && deferred.resolve();
                
                resolved = true;
            }

            return deferred.promise();
        },
        /**
         * 
         * @returns {object} $.Deferred().promise()
         */
        _setup: function () {

            var deferred = new $.Deferred(),
                tmpCache = {
                    text: this._textReplace(),
                    parent: {}
                };

            this.element.css({
                display: 'inline-block',
                lineHeight: this.options.lineHeight,
                opacity: 0
            }).html(tmpCache.text);


            tmpCache.parent.$element = this.element.parent();
            tmpCache.parent.width = tmpCache.parent.$element.width();
            tmpCache.displayMode = this.element.css('display');

            this.cache = tmpCache;

            deferred.resolve();

            return deferred.promise();
        },
        /**
         * 
         * @returns {string}
         */
        _textReplace: function () {
            return this.element.text().replace(/\s/igm, '&nbsp;'); //replace spaces with nbsp
        },
        /**
         * 
         * @returns {Boolean}
         */
        _checkContentChange: function () {
            var hasChanged = false;

            if (this.element.html() !== this.cache.text) {
                this.cache.text = this._textReplace();
                this.element.html(this.cache.text);
                hasChanged = true;
            }

            return hasChanged;
        },
        /**
         * This will allow T&T or any external procedure to
         * independently change the text without affecting
         * the text resizing behaviour
         * 
         * @returns {object} $.Deferred().promise()
         */
        _whatchForContentChange: function () {
            var deferred = new $.Deferred();

            if (parseInt(this.options.whatchForContentChange, 10)) {
                if (this.watchingInterval) {
                    clearInterval(this.watchingInterval);
                    this.watchingInterval = null;
                }

                this.watchingInterval = setInterval($.proxy(function () {
                    if (this.element.is(':visible') && (this._checkContentChange() || this._displayModeChanged())) {
                        this._fitText();

                        if (parseInt(this.options.whatchStopAfterContentChange, 10)) {
                            clearInterval(this.watchingInterval);
                            this.watchingInterval = null;
                        }
                    }
                }, this), 300);

            }

            deferred.resolve();

            return deferred.promise();
        },
        /**
         * 
         * @returns {displayMode|jquery.fitMe2_L8.jquery.fitMe2Anonym$0@pro;element@call;width}
         */
        _getProportion: function () {
            return this.cache.parent.width / (this.element.width() || 1);
        },
        /**
         * If the parent's width has changed
         * we will need to recalculate the font size
         * 
         * @returns {Boolean}
         */
        _widthHasChanged: function () {
            var parentWidth = this.cache.parent.$element.width(),
                hasChanged = parentWidth !== this.cache.parent.width;

            this.cache.parent.width = parentWidth;

            return hasChanged;
        },
        /**
         * If a css rule determinates after some action a change from e.g display:none to display:inline-block
         * we will need to recalculate the font size
         * 
         * @returns {Boolean}
         */
        _displayModeChanged: function () {
            var displayMode = this.element.css('display'),
                hasChanged = displayMode !== this.cache.displayMode;

            this.cache.displayMode = displayMode;

            return hasChanged;
        },
        /**
         * 
         * @returns {undefined}
         */
        _fitText: function () {
            var currentFontSize = parseInt(this.element.css('font-size'), 10),
                newFontSize;

            if (!this.element.hasClass(this.options.fittingClass) && this.element.is(':visible')) {

                newFontSize = currentFontSize * this._getProportion();

                if (this.options.maxFontSize && (newFontSize > this.options.maxFontSize)) {
                    newFontSize = this.options.maxFontSize;
                }

                this.element
                    .addClass(this.options.fittingClass)
                    .css({
                        fontSize: newFontSize,
                        opacity: 1
                    })
                    .removeClass(this.options.fittingClass);
            }
        },
        /**
         * 
         * @returns {undefined}
         */
        _addBindings: function () {

            $(window).on('resize.fitMe2', UW.util.throttle($.proxy(function () {
                (this._widthHasChanged() || this._displayModeChanged()) && this._fitText();
            }, this), this.options.debounceTime));

        }
    });

}(jQuery, window, document, window.UW || (window.UW = {})));
jQuery(function () {
    //Overlays
    if (jQuery(".overlay-trigger").length) {
        UW.util.loader.js(["/etc/designs/uwaem/assets/js/overlay.js", "/etc/designs/uwaem/assets/js/handlebars.js"], function () {
            jQuery(".overlay-trigger").overlay();
        });
    }

    //accordions
    if (jQuery(".widget-accordion").length) {
        UW.util.loader.js(["/etc/designs/uwaem/assets/js/accordion.js"], function () {
            jQuery(".widget-accordion").accordion();
        });
    }
    //accordions
    if (jQuery(".widget-tab").length) {
        UW.util.loader.js(["/etc/designs/uwaem/assets/js/accordion.js"], function () {
            jQuery(".widget-tab").accordion();
            UW.breakpoint.addBreakpointChangeListener().then(function () {
                jQuery(window).on('breakpoint.changed', function () {
                    if (UW.breakpoint.breakpoints[UW.breakpoint.getScreenSize()]>=UW.breakpoint.breakpoints.large){
                        jQuery(".widget-tab").each(
                            function(index,el){
                                el.options.toggle=false;
                                el.options.animationIn="fadeIn";
                                el.options.animationOut="fadeOut";
                            });
                    }else {
                        jQuery(".widget-tab").each(
                            function(index,el){
                                el.options.toggle=true;
                                el.options.animationIn="slideDown";
                                el.options.animationOut="slideUp";
                            });
                    }
                });
            });
        });
    }

    
    //
    if (jQuery(".widget-collapse").length) {
        UW.util.loader.js(["/etc/designs/uwaem/assets/js/collapse.js"], function () {
            jQuery(jQuery(".widget-collapse")[0]).collapse();
        });
    }

    //Twitter component    
    if (jQuery(".twitter-feed").length) {
        UW.util.loader.js(["/etc/designs/uwaem/assets/js/twitter.js", "//www.emc.com/R1/assets/js/common/moment.js"], function () {
            jQuery('.tweets').twitterFeed();
        });
    }

    //FIT ME 2 (expant text to cover full container's width   
    if (jQuery(".fit-me-2").length) {
        // cannot lazy load due to event listener for font beign triggered before plugin is loaded
        jQuery('.fit-me-2').fitMe2({
            webfontListenerSelector: window,
            webfontListenerEvent: 'typekit.fonts.ready'
        });
    }
    
    
    /* I need to consider another option to make this, instead of having multiple instances*/
    if(jQuery(".match-height2").length){
        UW.util.loader.js(["/etc/designs/uwaem/manifests/js/plugins/matchHeight/matchHeight.min.js"], function () {
            jQuery(".match-height2").matchHeight(); 
        });
    }
    if(jQuery(".match-height3").length){
        UW.util.loader.js(["/etc/designs/uwaem/manifests/js/plugins/matchHeight/matchHeight.min.js"], function () {
            jQuery(".match-height3").matchHeight(); 
        });
    }
    if(jQuery(".match-height4").length){
        UW.util.loader.js(["/etc/designs/uwaem/manifests/js/plugins/matchHeight/matchHeight.min.js"], function () {
            jQuery(".match-height4").matchHeight(); 
        });
    }
    /******/
    
    
    if (jQuery(".widget-carousel").length) {
        UW.util.loader.js([
            "/etc/designs/uwaem/manifests/js/plugins/hammer/hammer.min.js",
            "/etc/designs/uwaem/manifests/js/plugins/hammer/jquery.hammer.min.js",
            "/etc/designs/uwaem/assets/js/carousel.js"
            ], function () {
            jQuery(".widget-carousel").carousel();
        });
    }
    
    
    //HERO CAROUSEL CANDIDATE
    if (jQuery('[data-implement="hero-carousel"]').length) {
        UW.util.loader.js([
            '/etc/designs/uwaem/manifests/js/plugins/hammer/hammer.min.js',
            '/etc/designs/uwaem/manifests/js/plugins/hammer/jquery.hammer.min.js',
            '/etc/designs/uwaem/manifests/js/plugins/hero-carousel-candidate/hero-carousel-candidate.js'
        ], function () {
            // activate all carousels
            jQuery('[data-implement="hero-carousel"]').heroCarousel();
        });
    }
});


/* js/common/responsive-header.js */

var $j=jQuery.noConflict();
var j=jQuery.noConflict();

// full absolute URL to login/logout pages of corresponding environment
var dotcomDomain='www.emc.com';
var loginURL='http://www.emc.com/login3.htm?r=';
var logoutURL='http://www.emc.com/login3.htm?r=';
//$j(document).ready(function() {
     dotcomDomain=$j('#emcLogo').closest('a').attr('href');
     if (typeof(dotcomDomain)=='undefined') {
       dotcomDomain='http://www.emc.com/';
     } else {
         if (dotcomDomain=='/') {
             dotcomDomain='http://'+window.location.hostname+'/';
         }
     }
     dotcomDomain=dotcomDomain.slice(dotcomDomain.indexOf('://')+3);
     dotcomDomain=dotcomDomain.slice(0,dotcomDomain.indexOf('/'));
     loginURL='http://'+dotcomDomain+'/login3.htm?r=';
     logoutURL='http://'+dotcomDomain+'/logout3.htm?r=';
//});

// Calculate scrollbar width in pixels.
var  isFirstLoad    = true,
     browserIsIE8   = (jQuery.browser.msie && parseInt(jQuery.browser.version, 10) === 8),
     smallSize      = 640,
     mediumSize     = 980,
     scrollbarWidthCache = 0;

function scrollbarWidthCalc() {
  
  if (!scrollbarWidthCache || scrollbarWidthCache < 1){

         var  $inner    = jQuery('<div style="height: 200px; width: 100%;"></div>'),
              $outer    = jQuery('<div style="height:150px; left: 0; overflow: hidden; position: absolute; top: 0; visibility: hidden; width: 200px;"></div>').append($inner),
              inner     = $inner[0],
              outer     = $outer[0];

         jQuery('body').append(outer);
         var width1 = inner.offsetWidth;
         $outer.css('overflow', 'scroll');
         var width2 = outer.clientWidth;
         $outer.remove();

         scrollbarWidthCache = (width1 - width2);
   }
  
     return scrollbarWidthCache;

}

// send debug info to console if present, otherwise fail silently
function trace() {
     if (typeof(console)!='undefined') {
    if (typeof(console.log)!='undefined') {
         for (i=0;i<arguments.length;i++) {
        console.log(arguments[i]);
         }
    }
     }
}

// cookies

function createCookie(name,value,days) {
  //console.log('create cookie '+name+' '+value+' '+days);
  var expires='';
  if (days!=undefined) {
    var date = new Date();
    date.setTime(date.getTime()+(days*24*60*60*1000));
    expires = '';//"; expires="+date.toGMTString();
  }
  document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name) {
     var nameEQ = name + "=";
     var ca = document.cookie.split(';');
     for (var i=0;i < ca.length;i++) {
          var c = ca[i];
          while (c.charAt(0)==' ') c = c.substring(1,c.length);
          if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
     }
     return null;
}

function eraseCookie(name) {
     createCookie(name,"",-1);
}


function isRemoteSite() {
     var isRemote=false;
     if (window.location.hostname.indexOf('store')>=0 ||
          window.location.hostname.indexOf('ebz')>=0 ||
          window.location.hostname.indexOf('community')>=0 ||
          window.location.hostname.indexOf('ecn-staging')>=0 ||
          window.location.hostname.indexOf('ecn-dev')>=0 ||
          window.location.hostname.indexOf('support')>=0 ||
          $j('body').hasClass('emc-support') ||
          window.location.hostname.indexOf('.local')>=0
     ) {
          isRemote=true;
          //$j('html').addClass('emc-global-nav-is-remote-site');
     }
     return isRemote;
}

/* =========== BEGIN Cufon-yui === */

/*
 * Copyright (c) 2009 Simo Kinnunen.
 * Licensed under the MIT license.
 *
 * @version 1.09i
 */
var Cufon=(function(){var m=function(){return m.replace.apply(null,arguments)};var x=m.DOM={ready:(function(){var C=false,E={loaded:1,complete:1};var B=[],D=function(){if(C){return}C=true;for(var F;F=B.shift();F()){}};if(document.addEventListener){document.addEventListener("DOMContentLoaded",D,false);window.addEventListener("pageshow",D,false)}if(!window.opera&&document.readyState){(function(){E[document.readyState]?D():setTimeout(arguments.callee,10)})()}if(document.readyState&&document.createStyleSheet){(function(){try{document.body.doScroll("left");D()}catch(F){setTimeout(arguments.callee,1)}})()}q(window,"load",D);return function(F){if(!arguments.length){D()}else{C?F():B.push(F)}}})(),root:function(){return document.documentElement||document.body}};var n=m.CSS={Size:function(C,B){this.value=parseFloat(C);this.unit=String(C).match(/[a-z%]*$/)[0]||"px";this.convert=function(D){return D/B*this.value};this.convertFrom=function(D){return D/this.value*B};this.toString=function(){return this.value+this.unit}},addClass:function(C,B){var D=C.className;C.className=D+(D&&" ")+B;return C},color:j(function(C){var B={};B.color=C.replace(/^rgba\((.*?),\s*([\d.]+)\)/,function(E,D,F){B.opacity=parseFloat(F);return"rgb("+D+")"});return B}),fontStretch:j(function(B){if(typeof B=="number"){return B}if(/%$/.test(B)){return parseFloat(B)/100}return{"ultra-condensed":0.5,"extra-condensed":0.625,condensed:0.75,"semi-condensed":0.875,"semi-expanded":1.125,expanded:1.25,"extra-expanded":1.5,"ultra-expanded":2}[B]||1}),getStyle:function(C){var B=document.defaultView;if(B&&B.getComputedStyle){return new a(B.getComputedStyle(C,null))}if(C.currentStyle){return new a(C.currentStyle)}return new a(C.style)},gradient:j(function(F){var G={id:F,type:F.match(/^-([a-z]+)-gradient\(/)[1],stops:[]},C=F.substr(F.indexOf("(")).match(/([\d.]+=)?(#[a-f0-9]+|[a-z]+\(.*?\)|[a-z]+)/ig);for(var E=0,B=C.length,D;E<B;++E){D=C[E].split("=",2).reverse();G.stops.push([D[1]||E/(B-1),D[0]])}return G}),quotedList:j(function(E){var D=[],C=/\s*((["'])([\s\S]*?[^\\])\2|[^,]+)\s*/g,B;while(B=C.exec(E)){D.push(B[3]||B[1])}return D}),recognizesMedia:j(function(G){var E=document.createElement("style"),D,C,B;E.type="text/css";E.media=G;try{E.appendChild(document.createTextNode("/**/"))}catch(F){}C=g("head")[0];C.insertBefore(E,C.firstChild);D=(E.sheet||E.styleSheet);B=D&&!D.disabled;C.removeChild(E);return B}),removeClass:function(D,C){var B=RegExp("(?:^|\\s+)"+C+"(?=\\s|$)","g");D.className=D.className.replace(B,"");return D},supports:function(D,C){var B=document.createElement("span").style;if(B[D]===undefined){return false}B[D]=C;return B[D]===C},textAlign:function(E,D,B,C){if(D.get("textAlign")=="right"){if(B>0){E=" "+E}}else{if(B<C-1){E+=" "}}return E},textShadow:j(function(F){if(F=="none"){return null}var E=[],G={},B,C=0;var D=/(#[a-f0-9]+|[a-z]+\(.*?\)|[a-z]+)|(-?[\d.]+[a-z%]*)|,/ig;while(B=D.exec(F)){if(B[0]==","){E.push(G);G={};C=0}else{if(B[1]){G.color=B[1]}else{G[["offX","offY","blur"][C++]]=B[2]}}}E.push(G);return E}),textTransform:(function(){var B={uppercase:function(C){return C.toUpperCase()},lowercase:function(C){return C.toLowerCase()},capitalize:function(C){return C.replace(/\b./g,function(D){return D.toUpperCase()})}};return function(E,D){var C=B[D.get("textTransform")];return C?C(E):E}})(),whiteSpace:(function(){var D={inline:1,"inline-block":1,"run-in":1};var C=/^\s+/,B=/\s+$/;return function(H,F,G,E){if(E){if(E.nodeName.toLowerCase()=="br"){H=H.replace(C,"")}}if(D[F.get("display")]){return H}if(!G.previousSibling){H=H.replace(C,"")}if(!G.nextSibling){H=H.replace(B,"")}return H}})()};n.ready=(function(){var B=!n.recognizesMedia("all"),E=false;var D=[],H=function(){B=true;for(var K;K=D.shift();K()){}};var I=g("link"),J=g("style");function C(K){return K.disabled||G(K.sheet,K.media||"screen")}function G(M,P){if(!n.recognizesMedia(P||"all")){return true}if(!M||M.disabled){return false}try{var Q=M.cssRules,O;if(Q){search:for(var L=0,K=Q.length;O=Q[L],L<K;++L){switch(O.type){case 2:break;case 3:if(!G(O.styleSheet,O.media.mediaText)){return false}break;default:break search}}}}catch(N){}return true}function F(){if(document.createStyleSheet){return true}var L,K;for(K=0;L=I[K];++K){if(L.rel.toLowerCase()=="stylesheet"&&!C(L)){return false}}for(K=0;L=J[K];++K){if(!C(L)){return false}}return true}x.ready(function(){if(!E){E=n.getStyle(document.body).isUsable()}if(B||(E&&F())){H()}else{setTimeout(arguments.callee,10)}});return function(K){if(B){K()}else{D.push(K)}}})();function s(D){var C=this.face=D.face,B={"\u0020":1,"\u00a0":1,"\u3000":1};this.glyphs=D.glyphs;this.w=D.w;this.baseSize=parseInt(C["units-per-em"],10);this.family=C["font-family"].toLowerCase();this.weight=C["font-weight"];this.style=C["font-style"]||"normal";this.viewBox=(function(){var F=C.bbox.split(/\s+/);var E={minX:parseInt(F[0],10),minY:parseInt(F[1],10),maxX:parseInt(F[2],10),maxY:parseInt(F[3],10)};E.width=E.maxX-E.minX;E.height=E.maxY-E.minY;E.toString=function(){return[this.minX,this.minY,this.width,this.height].join(" ")};return E})();this.ascent=-parseInt(C.ascent,10);this.descent=-parseInt(C.descent,10);this.height=-this.ascent+this.descent;this.spacing=function(L,N,E){var O=this.glyphs,M,K,G,P=[],F=0,J=-1,I=-1,H;while(H=L[++J]){M=O[H]||this.missingGlyph;if(!M){continue}if(K){F-=G=K[H]||0;P[I]-=G}F+=P[++I]=~~(M.w||this.w)+N+(B[H]?E:0);K=M.k}P.total=F;return P}}function f(){var C={},B={oblique:"italic",italic:"oblique"};this.add=function(D){(C[D.style]||(C[D.style]={}))[D.weight]=D};this.get=function(H,I){var G=C[H]||C[B[H]]||C.normal||C.italic||C.oblique;if(!G){return null}I={normal:400,bold:700}[I]||parseInt(I,10);if(G[I]){return G[I]}var E={1:1,99:0}[I%100],K=[],F,D;if(E===undefined){E=I>400}if(I==500){I=400}for(var J in G){if(!k(G,J)){continue}J=parseInt(J,10);if(!F||J<F){F=J}if(!D||J>D){D=J}K.push(J)}if(I<F){I=F}if(I>D){I=D}K.sort(function(M,L){return(E?(M>=I&&L>=I)?M<L:M>L:(M<=I&&L<=I)?M>L:M<L)?-1:1});return G[K[0]]}}function r(){function D(F,G){if(F.contains){return F.contains(G)}return F.compareDocumentPosition(G)&16}function B(G){var F=G.relatedTarget;if(!F||D(this,F)){return}C(this,G.type=="mouseover")}function E(F){C(this,F.type=="mouseenter")}function C(F,G){setTimeout(function(){var H=d.get(F).options;m.replace(F,G?h(H,H.hover):H,true)},10)}this.attach=function(F){if(F.onmouseenter===undefined){q(F,"mouseover",B);q(F,"mouseout",B)}else{q(F,"mouseenter",E);q(F,"mouseleave",E)}}}function u(){var C=[],D={};function B(H){var E=[],G;for(var F=0;G=H[F];++F){E[F]=C[D[G]]}return E}this.add=function(F,E){D[F]=C.push(E)-1};this.repeat=function(){var E=arguments.length?B(arguments):C,F;for(var G=0;F=E[G++];){m.replace(F[0],F[1],true)}}}function A(){var D={},B=0;function C(E){return E.cufid||(E.cufid=++B)}this.get=function(E){var F=C(E);return D[F]||(D[F]={})}}function a(B){var D={},C={};this.extend=function(E){for(var F in E){if(k(E,F)){D[F]=E[F]}}return this};this.get=function(E){return D[E]!=undefined?D[E]:B[E]};this.getSize=function(F,E){return C[F]||(C[F]=new n.Size(this.get(F),E))};this.isUsable=function(){return !!B}}function q(C,B,D){if(C.addEventListener){C.addEventListener(B,D,false)}else{if(C.attachEvent){C.attachEvent("on"+B,function(){return D.call(C,window.event)})}}}function v(C,B){var D=d.get(C);if(D.options){return C}if(B.hover&&B.hoverables[C.nodeName.toLowerCase()]){b.attach(C)}D.options=B;return C}function j(B){var C={};return function(D){if(!k(C,D)){C[D]=B.apply(null,arguments)}return C[D]}}function c(F,E){var B=n.quotedList(E.get("fontFamily").toLowerCase()),D;for(var C=0;D=B[C];++C){if(i[D]){return i[D].get(E.get("fontStyle"),E.get("fontWeight"))}}return null}function g(B){return document.getElementsByTagName(B)}function k(C,B){return C.hasOwnProperty(B)}function h(){var C={},B,F;for(var E=0,D=arguments.length;B=arguments[E],E<D;++E){for(F in B){if(k(B,F)){C[F]=B[F]}}}return C}function o(E,M,C,N,F,D){var K=document.createDocumentFragment(),H;if(M===""){return K}var L=N.separate;var I=M.split(p[L]),B=(L=="words");if(B&&t){if(/^\s/.test(M)){I.unshift("")}if(/\s$/.test(M)){I.push("")}}for(var J=0,G=I.length;J<G;++J){H=z[N.engine](E,B?n.textAlign(I[J],C,J,G):I[J],C,N,F,D,J<G-1);if(H){K.appendChild(H)}}return K}function l(D,M){var C=D.nodeName.toLowerCase();if(M.ignore[C]){return}var E=!M.textless[C];var B=n.getStyle(v(D,M)).extend(M);var F=c(D,B),G,K,I,H,L,J;if(!F){return}for(G=D.firstChild;G;G=I){K=G.nodeType;I=G.nextSibling;if(E&&K==3){if(H){H.appendData(G.data);D.removeChild(G)}else{H=G}if(I){continue}}if(H){D.replaceChild(o(F,n.whiteSpace(H.data,B,H,J),B,M,G,D),H);H=null}if(K==1){if(G.firstChild){if(G.nodeName.toLowerCase()=="cufon"){z[M.engine](F,null,B,M,G,D)}else{arguments.callee(G,M)}}J=G}}}var t=" ".split(/\s+/).length==0;var d=new A();var b=new r();var y=new u();var e=false;var z={},i={},w={autoDetect:false,engine:null,forceHitArea:false,hover:false,hoverables:{a:true},ignore:{applet:1,canvas:1,col:1,colgroup:1,head:1,iframe:1,map:1,optgroup:1,option:1,script:1,select:1,style:1,textarea:1,title:1,pre:1},printable:true,selector:(window.Sizzle||(window.jQuery&&function(B){return $j(B)})||(window.dojo&&dojo.query)||(window.Ext&&Ext.query)||(window.YAHOO&&YAHOO.util&&YAHOO.util.Selector&&YAHOO.util.Selector.query)||(window.$$&&function(B){return $$(B)})||(window.$&&function(B){return $(B)})||(document.querySelectorAll&&function(B){return document.querySelectorAll(B)})||g),separate:"words",textless:{dl:1,html:1,ol:1,table:1,tbody:1,thead:1,tfoot:1,tr:1,ul:1},textShadow:"none"};var p={words:/\s/.test("\u00a0")?/[^\S\u00a0]+/:/\s+/,characters:"",none:/^/};m.now=function(){x.ready();return m};m.refresh=function(){y.repeat.apply(y,arguments);return m};m.registerEngine=function(C,B){if(!B){return m}z[C]=B;return m.set("engine",C)};m.registerFont=function(D){if(!D){return m}var B=new s(D),C=B.family;if(!i[C]){i[C]=new f()}i[C].add(B);return m.set("fontFamily",'"'+C+'"')};m.replace=function(D,C,B){C=h(w,C);if(!C.engine){return m}if(!e){n.addClass(x.root(),"cufon-active cufon-loading");n.ready(function(){n.addClass(n.removeClass(x.root(),"cufon-loading"),"cufon-ready")});e=true}if(C.hover){C.forceHitArea=true}if(C.autoDetect){delete C.fontFamily}if(typeof C.textShadow=="string"){C.textShadow=n.textShadow(C.textShadow)}if(typeof C.color=="string"&&/^-/.test(C.color)){C.textGradient=n.gradient(C.color)}else{delete C.textGradient}if(!B){y.add(D,arguments)}if(D.nodeType||typeof D=="string"){D=[D]}n.ready(function(){for(var F=0,E=D.length;F<E;++F){var G=D[F];if(typeof G=="string"){m.replace(C.selector(G),C,true)}else{l(G,C)}}});return m};m.set=function(B,C){w[B]=C;return m};return m})();Cufon.registerEngine("vml",(function(){var e=document.namespaces;if(!e){return}e.add("cvml","urn:schemas-microsoft-com:vml");e=null;var b=document.createElement("cvml:shape");b.style.behavior="url(#default#VML)";if(!b.coordsize){return}b=null;var h=(document.documentMode||0)<8;document.write(('<style type="text/css">cufoncanvas{text-indent:0;}@media screen{cvml\\:shape,cvml\\:rect,cvml\\:fill,cvml\\:shadow{behavior:url(#default#VML);display:block;antialias:true;position:absolute;}cufoncanvas{position:absolute;text-align:left;}cufon{display:inline-block;position:relative;vertical-align:'+(h?"middle":"text-bottom")+";}cufon cufontext{position:absolute;left:-10000in;font-size:1px;}a cufon{cursor:pointer}}@media print{cufon cufoncanvas{display:none;}}</style>").replace(/;/g,"!important;"));function c(i,j){return a(i,/(?:em|ex|%)$|^[a-z-]+$/i.test(j)?"1em":j)}function a(l,m){if(m==="0"){return 0}if(/px$/i.test(m)){return parseFloat(m)}var k=l.style.left,j=l.runtimeStyle.left;l.runtimeStyle.left=l.currentStyle.left;l.style.left=m.replace("%","em");var i=l.style.pixelLeft;l.style.left=k;l.runtimeStyle.left=j;return i}function f(l,k,j,n){var i="computed"+n,m=k[i];if(isNaN(m)){m=k.get(n);k[i]=m=(m=="normal")?0:~~j.convertFrom(a(l,m))}return m}var g={};function d(p){var q=p.id;if(!g[q]){var n=p.stops,o=document.createElement("cvml:fill"),i=[];o.type="gradient";o.angle=180;o.focus="0";o.method="sigma";o.color=n[0][1];for(var m=1,l=n.length-1;m<l;++m){i.push(n[m][0]*100+"% "+n[m][1])}o.colors=i.join(",");o.color2=n[l][1];g[q]=o}return g[q]}return function(ac,G,Y,C,K,ad,W){var n=(G===null);if(n){G=K.alt}var I=ac.viewBox;var p=Y.computedFontSize||(Y.computedFontSize=new Cufon.CSS.Size(c(ad,Y.get("fontSize"))+"px",ac.baseSize));var y,q;if(n){y=K;q=K.firstChild}else{y=document.createElement("cufon");y.className="cufon cufon-vml";y.alt=G;q=document.createElement("cufoncanvas");y.appendChild(q);if(C.printable){var Z=document.createElement("cufontext");Z.appendChild(document.createTextNode(G));y.appendChild(Z)}if(!W){y.appendChild(document.createElement("cvml:shape"))}}var ai=y.style;var R=q.style;var l=p.convert(I.height),af=Math.ceil(l);var V=af/l;var P=V*Cufon.CSS.fontStretch(Y.get("fontStretch"));var U=I.minX,T=I.minY;R.height=af;R.top=Math.round(p.convert(T-ac.ascent));R.left=Math.round(p.convert(U));ai.height=p.convert(ac.height)+"px";var F=Y.get("color");var ag=Cufon.CSS.textTransform(G,Y).split("");var L=ac.spacing(ag,f(ad,Y,p,"letterSpacing"),f(ad,Y,p,"wordSpacing"));if(!L.length){return null}var k=L.total;var x=-U+k+(I.width-L[L.length-1]);var ah=p.convert(x*P),X=Math.round(ah);var O=x+","+I.height,m;var J="r"+O+"ns";var u=C.textGradient&&d(C.textGradient);var o=ac.glyphs,S=0;var H=C.textShadow;var ab=-1,aa=0,w;while(w=ag[++ab]){var D=o[ag[ab]]||ac.missingGlyph,v;if(!D){continue}if(n){v=q.childNodes[aa];while(v.firstChild){v.removeChild(v.firstChild)}}else{v=document.createElement("cvml:shape");q.appendChild(v)}v.stroked="f";v.coordsize=O;v.coordorigin=m=(U-S)+","+T;v.path=(D.d?"m"+D.d+"xe":"")+"m"+m+J;v.fillcolor=F;if(u){v.appendChild(u.cloneNode(false))}var ae=v.style;ae.width=X;ae.height=af;if(H){var s=H[0],r=H[1];var B=Cufon.CSS.color(s.color),z;var N=document.createElement("cvml:shadow");N.on="t";N.color=B.color;N.offset=s.offX+","+s.offY;if(r){z=Cufon.CSS.color(r.color);N.type="double";N.color2=z.color;N.offset2=r.offX+","+r.offY}N.opacity=B.opacity||(z&&z.opacity)||1;v.appendChild(N)}S+=L[aa++]}var M=v.nextSibling,t,A;if(C.forceHitArea){if(!M){M=document.createElement("cvml:rect");M.stroked="f";M.className="cufon-vml-cover";t=document.createElement("cvml:fill");t.opacity=0;M.appendChild(t);q.appendChild(M)}A=M.style;A.width=X;A.height=af}else{if(M){q.removeChild(M)}}ai.width=Math.max(Math.ceil(p.convert(k*P)),0);if(h){var Q=Y.computedYAdjust;if(Q===undefined){var E=Y.get("lineHeight");if(E=="normal"){E="1em"}else{if(!isNaN(E)){E+="em"}}Y.computedYAdjust=Q=0.5*(a(ad,E)-parseFloat(ai.height))}if(Q){ai.marginTop=Math.ceil(Q)+"px";ai.marginBottom=Q+"px"}}return y}})());Cufon.registerEngine("canvas",(function(){var b=document.createElement("canvas");if(!b||!b.getContext||!b.getContext.apply){return}b=null;var a=Cufon.CSS.supports("display","inline-block");var e=!a&&(document.compatMode=="BackCompat"||/frameset|transitional/i.test(document.doctype.publicId));var f=document.createElement("style");f.type="text/css";f.appendChild(document.createTextNode(("cufon{text-indent:0;}@media screen,projection{cufon{display:inline;display:inline-block;position:relative;vertical-align:middle;"+(e?"":"font-size:1px;line-height:1px;")+"}cufon cufontext{display:-moz-inline-box;display:inline-block;width:0;height:0;overflow:hidden;text-indent:-10000in;}"+(a?"cufon canvas{position:relative;}":"cufon canvas{position:absolute;}")+"}@media print{cufon{padding:0;}cufon canvas{display:none;}}").replace(/;/g,"!important;")));document.getElementsByTagName("head")[0].appendChild(f);function d(p,h){var n=0,m=0;var g=[],o=/([mrvxe])([^a-z]*)/g,k;generate:for(var j=0;k=o.exec(p);++j){var l=k[2].split(",");switch(k[1]){case"v":g[j]={m:"bezierCurveTo",a:[n+~~l[0],m+~~l[1],n+~~l[2],m+~~l[3],n+=~~l[4],m+=~~l[5]]};break;case"r":g[j]={m:"lineTo",a:[n+=~~l[0],m+=~~l[1]]};break;case"m":g[j]={m:"moveTo",a:[n=~~l[0],m=~~l[1]]};break;case"x":g[j]={m:"closePath"};break;case"e":break generate}h[g[j].m].apply(h,g[j].a)}return g}function c(m,k){for(var j=0,h=m.length;j<h;++j){var g=m[j];k[g.m].apply(k,g.a)}}return function(V,w,P,t,C,W){var k=(w===null);if(k){w=C.getAttribute("alt")}var A=V.viewBox;var m=P.getSize("fontSize",V.baseSize);var B=0,O=0,N=0,u=0;var z=t.textShadow,L=[];if(z){for(var U=z.length;U--;){var F=z[U];var K=m.convertFrom(parseFloat(F.offX));var I=m.convertFrom(parseFloat(F.offY));L[U]=[K,I];if(I<B){B=I}if(K>O){O=K}if(I>N){N=I}if(K<u){u=K}}}var Z=Cufon.CSS.textTransform(w,P).split("");var E=V.spacing(Z,~~m.convertFrom(parseFloat(P.get("letterSpacing"))||0),~~m.convertFrom(parseFloat(P.get("wordSpacing"))||0));if(!E.length){return null}var h=E.total;O+=A.width-E[E.length-1];u+=A.minX;var s,n;if(k){s=C;n=C.firstChild}else{s=document.createElement("cufon");s.className="cufon cufon-canvas";s.setAttribute("alt",w);n=document.createElement("canvas");s.appendChild(n);if(t.printable){var S=document.createElement("cufontext");S.appendChild(document.createTextNode(w));s.appendChild(S)}}var aa=s.style;var H=n.style;var j=m.convert(A.height);var Y=Math.ceil(j);var M=Y/j;var G=M*Cufon.CSS.fontStretch(P.get("fontStretch"));var J=h*G;var Q=Math.ceil(m.convert(J+O-u));var o=Math.ceil(m.convert(A.height-B+N));n.width=Q;n.height=o;H.width=Q+"px";H.height=o+"px";B+=A.minY;H.top=Math.round(m.convert(B-V.ascent))+"px";H.left=Math.round(m.convert(u))+"px";var r=Math.max(Math.ceil(m.convert(J)),0)+"px";if(a){aa.width=r;aa.height=m.convert(V.height)+"px"}else{aa.paddingLeft=r;aa.paddingBottom=(m.convert(V.height)-1)+"px"}var X=n.getContext("2d"),D=j/A.height;X.scale(D,D*M);X.translate(-u,-B);X.save();function T(){var x=V.glyphs,ab,l=-1,g=-1,y;X.scale(G,1);while(y=Z[++l]){var ab=x[Z[l]]||V.missingGlyph;if(!ab){continue}if(ab.d){X.beginPath();if(ab.code){c(ab.code,X)}else{ab.code=d("m"+ab.d,X)}X.fill()}X.translate(E[++g],0)}X.restore()}if(z){for(var U=z.length;U--;){var F=z[U];X.save();X.fillStyle=F.color;X.translate.apply(X,L[U]);T()}}var q=t.textGradient;if(q){var v=q.stops,p=X.createLinearGradient(0,A.minY,0,A.maxY);for(var U=0,R=v.length;U<R;++U){p.addColorStop.apply(p,v[U])}X.fillStyle=p}else{X.fillStyle=P.get("color")}T();return s}})());

/*!
 * The following copyright notice may not be removed under any circumstances.
 *
 * Copyright:
 * < info@fontfont.de > Copyright Erik Spiekermann, 1991, 93, 98. Published by
 * FontShop International for  FontFont Release 23, Meta is a trademark of FSI
 * Fonts and Software GmbH.
 */
Cufon.registerFont({"w":93,"face":{"font-family":"Meta","font-weight":400,"font-stretch":"normal","units-per-em":"360","panose-1":"2 0 5 3 0 0 0 0 0 0","ascent":"288","descent":"-72","x-height":"5","bbox":"-17 -333 339 75","underline-thickness":"7.2","underline-position":"-51.12","unicode-range":"U+0020-U+2122"},"glyphs":{" ":{"w":82},"!":{"d":"68,-252r-7,181r-21,0r-7,-176xm73,-20v0,13,-10,23,-22,23v-12,0,-22,-11,-22,-23v0,-12,10,-22,22,-22v12,0,22,10,22,22","w":101},"\"":{"d":"111,-168r-26,0r0,-87r26,0r0,87xm58,-168r-26,0r0,-87r26,0r0,87","w":143},"#":{"d":"189,-155r-38,0r-8,55r36,0r0,23r-39,0r-11,77r-24,0r11,-77r-46,0r-11,77r-24,0r11,-77r-35,0r0,-23r39,0r7,-55r-35,0r0,-24r38,0r11,-76r24,0r-10,76r45,0r11,-76r24,0r-11,76r35,0r0,24xm127,-155r-46,0r-7,55r45,0","w":200},"$":{"d":"127,-138v86,15,72,135,-12,142r0,35r-21,0r0,-34v-28,0,-53,-9,-76,-23r13,-23v20,14,40,22,63,22r0,-97v-39,-11,-67,-23,-68,-65v0,-39,27,-67,68,-71r0,-30r21,0r0,30v23,2,44,9,65,23r-13,22v-21,-13,-35,-20,-52,-21r0,86xm94,-148r0,-79v-46,6,-50,68,0,79xm154,-66v0,-21,-13,-34,-39,-43r0,88v23,-4,39,-23,39,-45","w":204},"%":{"d":"291,-56v0,37,-22,60,-58,60v-36,0,-58,-24,-58,-62v0,-38,22,-62,58,-62v40,0,58,27,58,64xm225,-245r-120,245r-23,0r120,-245r23,0xm130,-185v0,37,-22,59,-58,59v-36,0,-58,-24,-58,-62v0,-38,22,-61,58,-61v40,0,58,27,58,64xm267,-55v0,-21,-4,-45,-35,-45v-23,0,-33,15,-33,39v0,30,9,45,35,45v21,0,33,-14,33,-39xm106,-184v0,-21,-3,-45,-34,-45v-23,0,-33,15,-33,39v0,30,8,45,34,45v21,0,33,-14,33,-39","w":305},"&":{"d":"237,0r-37,0r-24,-23v-35,48,-154,32,-154,-38v0,-31,19,-48,50,-63v-23,-21,-35,-37,-35,-55v0,-33,30,-57,64,-57v36,0,66,19,66,55v0,28,-18,42,-51,60r58,57v6,-14,6,-37,6,-56r25,0v0,43,-5,60,-13,75xm136,-181v0,-20,-13,-35,-34,-35v-17,0,-35,10,-35,33v0,14,6,23,33,46v28,-13,36,-27,36,-44xm160,-40r-71,-69v-51,19,-49,93,17,92v24,0,45,-10,54,-23","w":242},"\u2019":{"d":"44,-251v33,1,34,49,14,71v-8,8,-19,19,-30,25r-10,-16v14,-7,22,-18,24,-32v-13,4,-24,-8,-24,-22v0,-14,12,-26,26,-26"},"(":{"d":"61,-116v0,73,14,133,63,157r-8,15v-92,-22,-108,-228,-49,-295v14,-16,31,-31,49,-38r7,13v-46,23,-62,75,-62,148","w":113},")":{"d":"-3,-278v55,18,86,95,84,171v-2,94,-28,134,-84,162r-7,-14v46,-23,62,-73,62,-147v0,-74,-13,-134,-63,-158","w":113},"*":{"d":"152,-198r-51,18r32,42r-17,14r-33,-44r-31,44r-18,-14r31,-42r-51,-18r7,-21r51,18r0,-54r22,0r0,54r51,-18","w":166},"+":{"d":"172,-77r-64,0r0,64r-26,0r0,-64r-64,0r0,-26r64,0r0,-64r26,0r0,64r64,0r0,26","w":190},",":{"d":"47,-45v33,1,36,50,15,72v-8,8,-19,18,-30,24r-10,-15v14,-7,22,-18,24,-32v-15,1,-23,-9,-24,-23v0,-14,11,-26,25,-26","w":100},"-":{"d":"87,-82r-69,0r0,-28r69,0r0,28","w":104},".":{"d":"73,-20v0,14,-10,25,-23,25v-14,0,-25,-11,-25,-25v0,-13,11,-24,24,-24v14,0,24,11,24,24","w":98},"\/":{"d":"139,-273r-94,326r-23,0r93,-326r24,0","w":160},"0":{"d":"183,-118v0,73,-34,124,-84,124v-118,0,-97,-247,1,-246v62,0,83,72,83,122xm100,-16v71,-4,72,-197,0,-201v-68,6,-68,197,0,201","w":201},"1":{"d":"158,0r-106,0r0,-23r41,0r0,-178v-6,5,-43,24,-57,30r-6,-15r69,-49r22,0r0,212r37,0r0,23","w":201},"2":{"d":"172,-173v3,61,-81,126,-106,151v25,-2,76,-1,106,-1r-5,23r-138,0r0,-16v30,-21,120,-116,110,-152v-1,-57,-67,-56,-99,-24r-12,-14v49,-52,140,-42,144,33","w":201},"3":{"d":"63,-139v48,2,72,-2,72,-38v0,-51,-72,-45,-100,-17r-13,-15v37,-43,145,-41,144,28v0,26,-17,47,-44,54v27,6,50,25,50,55v0,59,-67,90,-140,83r-6,-20v53,10,114,-14,114,-66v0,-37,-24,-46,-77,-43r0,-21","w":201},"4":{"d":"182,-45r-30,0v1,9,1,34,1,46r-28,9r0,-55r-107,0r0,-22r85,-169r32,0r-87,170v21,-2,53,-1,77,-1r5,-94r23,-6r-1,100r30,0r0,22","w":201},"5":{"d":"71,-140v57,-8,98,17,99,67v1,57,-66,99,-130,82r-5,-21v49,18,104,-17,104,-61v0,-48,-61,-56,-99,-39r11,-121r107,0r-4,24r-77,0","w":201},"6":{"d":"184,-72v0,45,-35,78,-80,78v-89,0,-102,-137,-46,-192v30,-29,58,-51,97,-63r7,18v-48,19,-92,47,-103,106v44,-39,125,-11,125,53xm151,-72v0,-54,-60,-63,-93,-31v-4,41,2,87,46,87v29,0,47,-22,47,-56","w":201},"7":{"d":"183,-233r-7,29v-42,58,-86,127,-104,208r-35,8v13,-64,77,-178,117,-221r-128,0r7,-24r150,0","w":201},"8":{"d":"181,-65v0,45,-40,71,-81,71v-46,0,-80,-28,-80,-66v0,-32,23,-54,51,-64v-27,-13,-43,-33,-43,-56v-3,-81,146,-75,146,-5v0,31,-25,49,-51,59v28,13,58,24,58,61xm146,-183v0,-22,-17,-36,-45,-36v-27,0,-45,15,-45,37v0,26,28,39,49,47v29,-15,41,-31,41,-48xm102,-15v41,0,64,-40,41,-69v-8,-9,-22,-17,-54,-31v-52,14,-55,100,13,100","w":201},"9":{"d":"106,-240v104,0,88,147,29,203v-25,23,-63,49,-104,54r-14,-17v61,-11,102,-45,125,-99v-48,34,-117,3,-117,-60v0,-46,36,-81,81,-81xm148,-125v14,-44,-8,-93,-44,-93v-28,0,-47,24,-47,59v-1,58,56,67,91,34","w":201},":":{"d":"77,-134v0,14,-11,25,-24,25v-13,0,-24,-11,-24,-24v0,-14,10,-25,24,-25v13,0,24,11,24,24xm77,-20v0,14,-10,24,-24,24v-13,0,-24,-11,-24,-24v0,-14,10,-24,24,-24v13,0,24,11,24,24","w":105},";":{"d":"77,-134v0,14,-11,25,-24,25v-13,0,-24,-12,-24,-26v0,-13,11,-23,24,-23v13,0,24,11,24,24xm54,-45v33,1,36,50,15,72v-8,8,-19,18,-30,24r-10,-15v14,-7,22,-18,24,-32v-15,1,-23,-9,-24,-23v0,-14,11,-26,25,-26","w":111},"<":{"d":"100,-31r-24,16r-69,-93r69,-93r24,16r-58,77","w":114},"=":{"d":"206,-125r-188,0r0,-24r188,0r0,24xm206,-69r-188,0r0,-24r188,0r0,24","w":223},">":{"d":"107,-108r-69,93r-24,-16r58,-77r-58,-77r24,-16","w":114},"?":{"d":"136,-197v-6,67,-70,49,-54,117r-24,0v-7,-28,-4,-53,17,-72v14,-13,33,-19,33,-44v0,-40,-55,-34,-82,-13r-12,-20v37,-31,127,-31,122,32xm97,-20v0,14,-11,25,-24,25v-13,0,-24,-11,-24,-25v0,-13,11,-24,24,-24v13,0,24,11,24,24","w":154},"@":{"d":"306,-100v0,64,-37,105,-78,105v-33,0,-40,-23,-37,-42v-20,41,-94,62,-98,-14v-4,-74,66,-139,139,-101r-22,99v-6,29,-1,39,19,39v29,0,52,-38,52,-86v0,-59,-46,-106,-114,-106v-73,0,-119,65,-119,133v0,85,80,132,162,106r5,19v-96,26,-194,-20,-193,-125v0,-85,61,-152,145,-152v78,0,139,49,139,125xm204,-139v-54,-23,-86,44,-86,90v0,21,7,28,22,28v17,0,42,-16,49,-50","w":327},"A":{"d":"204,0r-33,0r-23,-76r-93,0r-23,76r-30,0r82,-247r39,0xm140,-100r-38,-121r-39,121r77,0","w":206},"B":{"d":"139,-131v35,4,58,31,55,63v-4,50,-27,72,-98,68r-64,0r0,-247v86,-3,152,-3,152,62v0,26,-17,45,-45,54xm61,-141v46,1,90,6,90,-40v0,-42,-43,-44,-90,-41r0,81xm163,-70v0,-50,-49,-48,-102,-46r0,92v50,1,102,5,102,-46","w":215},"C":{"d":"54,-118v0,81,63,123,122,82r16,20v-20,13,-45,20,-69,20v-62,1,-101,-60,-101,-127v0,-101,90,-160,166,-107r-16,19v-63,-42,-118,9,-118,93","w":202},"D":{"d":"82,-247v85,-5,120,44,121,124v2,107,-63,133,-171,123r0,-247r50,0xm154,-50v35,-62,21,-182,-63,-173r-29,0r0,199v41,0,75,5,92,-26","w":224},"E":{"d":"171,0r-139,0r0,-247r135,0r-4,25r-101,0r0,81r85,0r0,25r-85,0r0,90r109,0r0,26","w":183},"F":{"d":"162,-247r-4,25r-96,0r0,81r79,0r0,24r-79,0r0,117r-30,0r0,-247r130,0","w":155},"G":{"d":"54,-122v0,79,50,120,116,92r0,-75r-50,0r-6,-25r84,0r0,115v-82,49,-188,-3,-176,-108v-11,-103,96,-163,170,-102r-13,18v-20,-14,-35,-19,-54,-19v-51,-2,-71,48,-71,104","w":226},"H":{"d":"195,0r-30,0r0,-120r-104,0r0,120r-29,0r0,-247r29,0r0,103r104,0r0,-103r30,0r0,247","w":227},"I":{"d":"61,0r-29,0r0,-247r29,0r0,247"},"J":{"d":"-1,28v28,-15,36,-21,36,-69r0,-206r29,0r0,205v2,59,-13,71,-50,88","w":96},"K":{"d":"197,-247r-100,116r99,131r-38,0r-94,-131r95,-116r38,0xm62,0r-30,0r0,-247r30,0r0,247","w":196},"L":{"d":"159,-25r-3,25r-124,0r0,-247r30,0r0,222r97,0","w":163},"M":{"d":"263,0r-29,0r-17,-223v-16,72,-43,152,-62,223r-25,0r-62,-224r-16,224r-29,0r22,-247r43,0r55,205v12,-61,39,-143,55,-205r44,0","w":286},"N":{"d":"197,0r-31,0r-80,-151v-16,-30,-28,-60,-28,-60v5,42,5,154,5,211r-31,0r0,-247r35,0r82,158v13,24,23,52,23,52v-5,-39,-5,-155,-5,-210r30,0r0,247","w":228},"O":{"d":"120,-251v82,0,97,52,100,131v3,74,-33,125,-99,125v-68,0,-99,-56,-99,-130v0,-78,37,-126,98,-126xm123,-18v50,0,64,-32,64,-97v0,-69,-8,-113,-67,-113v-50,0,-66,39,-66,97v0,67,13,113,69,113","w":241},"P":{"d":"101,-247v56,-3,83,28,85,71v2,65,-53,86,-125,78r0,98r-29,0r0,-247r69,0xm61,-122v51,4,93,-3,93,-49v0,-49,-40,-54,-93,-51r0,100","w":193},"Q":{"d":"120,-251v123,0,127,201,48,244v24,8,45,34,81,25v-7,14,-6,29,-31,27v-40,-5,-56,-36,-99,-40v-70,-6,-97,-56,-97,-130v0,-78,37,-126,98,-126xm123,-18v50,0,64,-34,64,-97v0,-69,-5,-113,-67,-113v-49,0,-66,39,-66,97v1,66,12,113,69,113","w":241},"R":{"d":"90,-247v62,2,87,15,87,68v0,42,-28,68,-69,67v35,35,52,74,81,112r-37,0v-7,-16,-30,-54,-63,-96v-10,-12,-15,-16,-27,-16r0,112r-30,0r0,-247r58,0xm62,-130v49,3,85,-4,84,-50v0,-38,-39,-45,-84,-42r0,92","w":196},"S":{"d":"31,-41v37,33,122,32,123,-25v2,-65,-128,-36,-128,-115v0,-74,102,-90,154,-48r-13,22v-24,-15,-39,-21,-60,-21v-31,0,-49,15,-49,40v0,48,90,44,113,75v40,53,-6,118,-74,118v-30,0,-55,-8,-79,-23","w":204},"T":{"d":"171,-247r-2,25r-67,0r0,222r-29,0r0,-222r-66,0r0,-25r164,0","w":163},"U":{"d":"112,-21v38,2,53,-17,53,-54r0,-172r29,0r0,176v2,59,-29,73,-83,75v-52,2,-81,-25,-80,-74r0,-177r29,0r0,166v1,41,5,58,52,60","w":225},"V":{"d":"201,-247r-85,247r-29,0r-83,-247r32,0r52,159v7,22,13,48,14,55r68,-214r31,0","w":204},"W":{"d":"285,-247r-56,247r-39,0r-31,-137v-9,-39,-12,-70,-12,-70r-43,207r-38,0r-59,-247r32,0r45,220r46,-220r34,0r47,220v7,-47,33,-164,45,-220r29,0","w":292},"X":{"d":"191,0r-35,0r-62,-113r-58,113r-34,0r73,-132r-66,-115r35,0r50,91r47,-91r34,0r-62,112","w":192},"Y":{"d":"187,-247r-80,151r0,96r-31,0r0,-98r-80,-149r37,0r59,122r61,-122r34,0","w":183},"Z":{"d":"168,-25r-7,25r-147,0r0,-23r122,-199r-118,0r8,-25r141,0r0,25r-118,197r119,0","w":182},"[":{"d":"92,56r-60,0r0,-320r60,0r0,22r-34,0r0,277r34,0r0,21","w":99},"\\":{"d":"138,6r-22,9r-109,-276r23,-9","w":145},"]":{"d":"67,56r-60,0r0,-21r34,0r0,-277r-34,0r0,-22r60,0r0,320","w":99},"^":{"d":"204,-99r-27,0r-64,-126r-65,126r-26,0r80,-156r21,0","w":225},"_":{"d":"180,45r-180,0r0,-18r180,0r0,18","w":180},"\u2018":{"d":"76,-240v-14,7,-23,18,-25,32v15,-1,23,9,24,23v0,14,-11,26,-25,26v-32,-1,-35,-50,-15,-72v8,-8,20,-19,31,-25"},"a":{"d":"26,-160v48,-35,141,-40,129,44v2,34,-11,95,13,103r-14,20v-12,-4,-22,-13,-25,-26v-17,17,-31,24,-52,24v-44,0,-57,-27,-57,-51v-1,-44,43,-68,107,-65v14,-68,-60,-52,-87,-29xm127,-91v-44,-5,-76,11,-76,42v0,47,64,38,75,5","w":186},"b":{"d":"181,-92v0,84,-74,124,-121,73v-1,8,-1,12,-5,19r-28,0v10,-68,7,-185,1,-258r28,-5v4,9,5,79,4,104v50,-52,121,-15,121,67xm104,-21v37,0,40,-24,45,-73v7,-69,-61,-80,-89,-40r0,92v9,12,27,21,44,21","w":202},"c":{"d":"131,-145v-43,-36,-86,3,-78,64v-5,62,51,82,82,43r16,18v-50,53,-139,12,-129,-67v-7,-82,72,-121,124,-78","w":165},"d":{"d":"22,-88v-8,-72,73,-126,120,-72v-2,-24,-1,-74,-1,-103r29,5r0,200v0,31,1,48,5,58v-19,-2,-35,8,-33,-18v-46,48,-128,9,-120,-70xm96,-21v18,1,41,-15,45,-25r0,-95v-32,-39,-101,-11,-88,52v-2,41,10,66,43,68","w":201},"e":{"d":"97,-184v51,0,71,32,69,99r-112,0v-9,64,59,84,97,49r11,18v-56,47,-140,16,-140,-73v0,-52,28,-93,75,-93xm136,-106v0,-36,-10,-56,-41,-56v-26,0,-40,19,-41,56r82,0","w":183},"f":{"d":"32,-179v-11,-71,41,-100,91,-71r-10,20v-19,-14,-54,-14,-51,23r0,28r50,0r-9,21r-41,0r0,158r-30,0r0,-158r-17,0r0,-21r17,0","w":105},"g":{"d":"135,14v0,-55,-105,-2,-107,-54v0,-14,8,-23,32,-31v-24,-8,-40,-27,-40,-51v0,-36,27,-61,66,-61v35,1,52,21,80,2r17,18v-14,10,-26,12,-42,8v28,36,-1,92,-50,88v-24,9,-32,15,-32,21v1,13,28,9,43,9v39,0,63,18,63,47v0,39,-27,57,-71,57v-65,0,-87,-23,-74,-65r29,-2v-16,27,11,45,42,45v28,0,44,-9,44,-31xm119,-124v0,-24,-9,-36,-33,-36v-22,0,-34,12,-34,37v0,23,11,36,34,36v22,0,33,-13,33,-37","w":181},"h":{"d":"59,-154v29,-38,109,-44,109,25r0,129r-28,0r0,-124v1,-55,-59,-34,-80,-3r0,127r-28,0r0,-221v0,-23,-4,-37,-4,-37r28,-5v4,8,5,89,3,109","w":200},"i":{"d":"69,-235v0,12,-9,22,-21,22v-12,0,-22,-9,-22,-21v0,-12,10,-23,22,-23v12,0,21,10,21,22xm62,0r-30,0r0,-179r30,-4r0,183"},"j":{"d":"69,-235v0,12,-10,22,-22,22v-12,0,-22,-10,-22,-22v0,-12,10,-22,22,-22v12,0,22,10,22,22xm61,-184v-3,72,6,156,-5,220v-7,17,-20,27,-37,35r-14,-18v25,-11,27,-28,27,-59r0,-172"},"k":{"d":"181,0r-37,0r-82,-102r68,-77r35,0r-70,77xm60,0r-28,0r0,-221v0,-23,-4,-37,-4,-37r28,-5v8,71,2,182,4,263","w":181},"l":{"d":"80,0v-24,10,-48,0,-48,-30r0,-190v0,-23,-4,-36,-4,-36r28,-6v10,54,3,159,5,226v-1,16,4,20,14,17"},"m":{"d":"129,-127v-2,-46,-44,-35,-70,-7r0,134r-27,0v-2,-52,5,-139,-6,-177r27,-7v0,0,7,14,7,27v23,-29,79,-41,94,3v31,-41,102,-42,102,19r0,135r-28,0r0,-132v-7,-45,-47,-26,-71,1r0,131r-28,0r0,-127","w":288},"n":{"d":"116,-183v26,0,49,17,48,47r0,136r-28,0r0,-121v3,-58,-53,-38,-76,-13r0,134r-28,0v-2,-52,5,-138,-6,-176r27,-8v0,0,6,13,6,28v19,-19,38,-27,57,-27","w":196},"o":{"d":"96,-185v56,0,77,39,78,98v0,60,-32,92,-77,92v-49,0,-77,-37,-77,-96v0,-58,29,-94,76,-94xm98,-19v33,0,44,-27,44,-66v0,-46,-11,-77,-46,-77v-35,0,-47,27,-46,67v1,45,9,76,48,76","w":194},"p":{"d":"59,-157v47,-56,131,-13,121,67v7,78,-68,123,-120,74r0,85r-28,6r0,-215v0,-27,-4,-39,-4,-39v21,1,35,-22,31,22xm60,-42v34,44,96,21,90,-44v-3,-41,-8,-72,-42,-72v-18,0,-34,9,-48,26r0,90","w":201},"q":{"d":"22,-84v-10,-87,70,-131,121,-75v0,-5,2,-16,4,-20r27,0v-10,59,-3,173,-5,246r-27,6r0,-93v-45,50,-129,13,-120,-64xm51,-91v6,56,8,70,47,70v18,0,35,-10,44,-28r0,-85v-30,-44,-98,-26,-91,43","w":201},"r":{"d":"109,-152v-24,-7,-49,12,-49,40r0,112r-28,0v-2,-52,5,-138,-6,-176r28,-8v0,0,7,14,6,29v16,-20,36,-35,60,-28","w":113},"s":{"d":"152,-53v0,62,-90,71,-134,40r11,-20v28,20,90,28,93,-15v2,-25,-29,-30,-52,-34v-30,-6,-45,-24,-45,-49v0,-54,76,-69,118,-41r-10,21v-27,-18,-76,-21,-79,17v-2,23,29,27,50,31v32,7,48,23,48,50","w":169},"t":{"d":"105,-1v-29,15,-73,7,-73,-34r0,-123r-23,0r0,-21r23,0v0,-17,3,-46,3,-46r30,-6v0,0,-4,28,-4,52r45,0r-8,21r-38,0r0,116v-4,28,22,30,41,23","w":111},"u":{"d":"58,-54v-2,54,65,40,79,4r0,-127r28,-5r0,131v0,23,3,31,12,39r-18,20v-12,-10,-17,-17,-20,-29v-26,40,-108,39,-108,-25r0,-132r27,-5r0,129","w":196},"v":{"d":"163,-179r-67,181r-28,0r-64,-180r28,-6r52,154v11,-45,35,-104,49,-149r30,0","w":166},"w":{"d":"241,-179r-51,180r-27,0r-42,-145r-40,145r-26,0r-50,-179r28,-6r37,148r38,-143r31,0r39,145r34,-145r29,0","w":246},"x":{"d":"165,0r-35,0r-48,-76r-49,76r-33,0r67,-99r-55,-80r34,0r36,59r34,-59r33,0r-53,80","w":164},"y":{"d":"158,-179r-62,185v-12,36,-26,60,-57,68r-9,-19v23,-7,32,-19,42,-55r-12,1v-13,-56,-38,-122,-56,-176r27,-10r37,117v6,17,9,45,12,44r46,-155r32,0","w":161},"z":{"d":"147,-22r-13,22r-120,0r0,-22r98,-135r-90,0r0,-22r119,0r0,23r-93,134r99,0","w":161},"{":{"d":"108,56v-38,3,-63,-5,-63,-45v0,-41,5,-106,-31,-104r0,-21v36,1,31,-64,31,-105v0,-40,26,-48,63,-45r0,22v-52,-11,-37,48,-37,92v0,33,-24,42,-31,47v8,1,31,10,31,46v0,38,-21,101,37,92r0,21","w":115},"|":{"d":"56,75r-24,0r0,-347r24,0r0,347","w":88},"}":{"d":"101,-93v-36,-2,-31,63,-31,104v0,40,-25,48,-63,45r0,-21v52,12,37,-48,37,-92v0,-38,24,-43,31,-47v-8,-2,-31,-14,-31,-46v0,-38,21,-101,-37,-92r0,-22v38,-3,63,5,63,45v0,42,-5,106,31,105r0,21","w":115},"~":{"d":"187,-117v-11,15,-23,32,-45,32v-39,0,-90,-50,-109,1r-11,-18v11,-15,23,-31,45,-31v39,0,90,50,108,-1","w":208},"\u00a1":{"d":"73,-166v0,12,-10,22,-22,22v-12,0,-22,-10,-22,-22v0,-13,10,-22,22,-22v12,0,22,10,22,22xm69,61r-36,5r7,-180r22,0","w":101},"\u00a2":{"d":"22,-87v1,-58,24,-86,65,-96r0,-28r20,0r0,28v17,2,28,9,39,18r-15,20v-10,-8,-16,-12,-24,-13r0,139v11,-3,20,-9,28,-19r16,18v-14,14,-27,21,-44,23r0,28r-20,0r0,-27v-44,-4,-66,-42,-65,-91xm87,-158v-47,8,-47,133,0,139r0,-139","w":165},"\u00a3":{"d":"192,-237r-20,21v-32,-35,-95,-13,-85,45r0,28r58,0r0,24r-58,0r0,91r89,0r0,28r-158,0r0,-28r39,0r0,-91r-35,0r0,-24r35,0v-6,-72,23,-116,77,-116v22,0,43,7,58,22","w":199},"\u00a5":{"d":"190,-247r-59,112r53,0r0,22r-64,0v-6,9,-12,17,-10,34r74,0r0,21r-74,0r0,58r-30,0r0,-58r-70,0r0,-21r70,0v2,-16,-3,-26,-9,-34r-61,0r0,-22r50,0r-60,-112r36,0r60,122r61,-122r33,0","w":190},"\u0192":{"d":"131,-250r-12,20v-19,-15,-52,-12,-51,23r-1,28r48,0r-10,21r-40,0r-9,138v-3,49,-3,66,-46,91r-14,-20v32,-20,30,-35,32,-68r9,-141r-16,0r0,-21r18,0v-11,-67,45,-99,92,-71","w":113},"\u00a7":{"d":"172,-102v0,22,-13,38,-31,48v15,10,25,25,25,45v-1,75,-123,82,-144,17r27,-13v7,40,85,44,85,-2v0,-47,-107,-43,-107,-103v0,-25,16,-41,37,-51v-17,-9,-28,-23,-28,-42v0,-67,106,-78,132,-25r-27,15v-12,-32,-75,-30,-75,9v0,28,32,32,51,43v23,14,55,27,55,59xm142,-97v-2,-29,-36,-36,-56,-49v-14,6,-31,13,-31,31v0,32,41,35,63,49v12,-5,24,-17,24,-31","w":193},"\u00a4":{"d":"89,-84v9,58,72,83,119,48r5,26v-63,37,-149,-5,-155,-74r-40,0r0,-21r37,0r-1,-29r-36,0r0,-22r39,0v9,-75,90,-116,152,-81r-5,26v-48,-36,-113,-5,-115,55r96,0r0,22r-99,0r0,29r99,0r0,21r-96,0","w":231},"'":{"d":"58,-168r-26,0r0,-87r26,0r0,87","w":90},"\u201c":{"d":"147,-240v-14,7,-23,18,-25,32v15,-1,23,9,24,23v0,14,-11,26,-25,26v-32,-1,-35,-50,-15,-72v8,-8,19,-19,30,-25xm76,-240v-14,7,-23,18,-25,32v15,-1,23,9,24,23v0,14,-11,26,-25,26v-32,-1,-35,-50,-15,-72v8,-8,20,-19,31,-25","w":164},"\u00ab":{"d":"160,-22r-20,13r-51,-77r51,-77r20,13r-42,64xm93,-22r-20,13r-51,-77r51,-77r20,13r-42,64","w":177},"\u2013":{"d":"193,-90r-175,0r0,-21r175,0r0,21","w":210},"\u00b7":{"d":"76,-100v0,13,-10,23,-23,23v-13,0,-24,-10,-24,-23v0,-13,10,-24,23,-24v13,0,24,11,24,24","w":104},"\u00b6":{"d":"180,45r-26,0r0,-276r-42,0r0,276r-26,0r0,-159v-44,0,-75,-30,-75,-67v0,-47,32,-74,82,-74r87,0r0,300","w":212},"\u2022":{"d":"156,-127v0,35,-28,63,-63,63v-35,0,-64,-28,-64,-63v0,-35,29,-64,64,-64v35,0,63,29,63,64","w":185},"\u201d":{"d":"114,-251v33,0,36,49,15,71v-8,8,-19,19,-30,25r-10,-16v14,-7,22,-18,24,-32v-13,4,-24,-8,-24,-22v0,-14,11,-26,25,-26xm44,-251v33,1,34,49,14,71v-8,8,-19,19,-30,25r-10,-16v14,-7,22,-18,24,-32v-13,4,-24,-8,-24,-22v0,-14,12,-26,26,-26","w":164},"\u00bb":{"d":"156,-86r-51,77r-20,-13r42,-64r-42,-64r20,-13xm89,-86r-51,77r-20,-13r42,-64r-42,-64r20,-13","w":177},"\u2026":{"d":"239,-20v0,14,-11,25,-24,25v-14,0,-24,-11,-24,-25v0,-13,11,-24,24,-24v14,0,24,11,24,24xm156,-20v0,14,-11,25,-24,25v-14,0,-24,-11,-24,-25v0,-13,11,-24,24,-24v14,0,24,11,24,24xm73,-20v0,14,-10,25,-23,25v-14,0,-25,-11,-25,-25v0,-13,11,-24,24,-24v14,0,24,11,24,24","w":264},"\u00bf":{"d":"105,-163v0,13,-11,24,-24,24v-13,0,-24,-11,-24,-24v0,-14,11,-25,24,-25v13,0,24,11,24,25xm18,14v6,-67,70,-49,54,-117r24,0v7,28,4,53,-17,72v-14,13,-33,19,-33,44v0,40,58,32,82,13r12,20v-37,31,-127,31,-122,-32","w":154},"`":{"d":"108,-220r-9,17r-81,-36r15,-28","w":126},"\u00b4":{"d":"108,-239r-81,36r-9,-17r75,-47","w":126},"\u00af":{"d":"106,-246r-99,0r0,-19r99,0r0,19","w":113},"\u00a8":{"d":"130,-224v0,10,-9,20,-19,20v-26,0,-23,-39,0,-38v10,0,19,8,19,18xm55,-224v0,10,-8,20,-18,20v-22,0,-26,-39,-1,-38v10,0,19,8,19,18","w":147},"\u00b8":{"d":"83,41v0,27,-45,38,-65,21r8,-17v13,6,32,12,34,-5v2,-15,-22,-5,-26,-13r7,-27r22,0r-4,15v18,3,24,13,24,26","w":100},"\u2014":{"d":"274,-90r-256,0r0,-21r256,0r0,21","w":292},"\u00c6":{"d":"302,0r-138,0r0,-77r-85,0r-47,77r-32,0r153,-247r146,0r-4,25r-101,0r0,81r84,0r0,25r-84,0r0,90r108,0r0,26xm164,-101r0,-118r-70,118r70,0","w":315},"\u00aa":{"d":"25,-257v38,-30,108,-28,98,33v2,26,-9,66,10,77r-12,16v-9,-3,-15,-11,-18,-20v-24,35,-89,14,-83,-21v-2,-33,35,-53,80,-48v8,-48,-40,-41,-64,-21xm131,-86r-113,0r0,-20r113,0r0,20xm100,-206v-32,-2,-56,6,-56,32v0,37,48,28,56,3r0,-35","w":150},"\u0141":{"d":"159,-25r-3,25r-124,0r0,-111r-24,8r0,-26r24,-8r0,-110r30,0r0,101r64,-21r0,26r-64,21r0,95r97,0","w":163},"\u00d8":{"d":"220,-120v0,95,-78,155,-152,108r-25,41r-19,-11r27,-45v-19,-22,-29,-56,-29,-98v0,-104,81,-154,154,-109r23,-39r19,12r-26,42v19,23,28,55,28,99xm120,-228v-79,0,-73,118,-54,176r96,-160v-10,-9,-24,-16,-42,-16xm81,-33v55,36,106,2,106,-82v0,-35,-4,-60,-11,-77","w":241},"\u0152":{"d":"22,-123v0,-80,29,-124,105,-124r170,0r-4,25r-101,0r0,81r85,0r0,25r-85,0r0,90r109,0r0,26r-158,0v-84,5,-121,-42,-121,-123xm54,-127v0,74,31,116,108,101r0,-193v-74,-16,-108,25,-108,92","w":313},"\u00ba":{"d":"134,-201v0,44,-22,69,-58,69v-36,0,-58,-28,-58,-72v0,-44,22,-70,57,-70v39,0,59,28,59,73xm132,-86r-112,0r0,-20r112,0r0,20xm108,-199v0,-44,-14,-55,-33,-55v-22,0,-32,16,-32,47v0,38,11,55,34,55v21,0,31,-14,31,-47","w":151},"\u00e6":{"d":"145,-161v50,-48,134,-16,120,76r-112,0v-11,57,58,87,96,49r11,18v-30,33,-104,26,-122,-9v-15,19,-40,32,-61,32v-45,0,-57,-29,-57,-51v-1,-44,43,-68,107,-65v12,-67,-55,-55,-87,-29r-14,-20v36,-25,95,-38,119,-1xm235,-106v0,-37,-12,-56,-41,-56v-26,0,-40,19,-41,56r82,0xm127,-91v-43,-5,-76,10,-76,42v0,47,64,38,75,5","w":282},"\u0131":{"d":"62,0r-30,0r0,-179r30,-4r0,183"},"\u0142":{"d":"78,0v-24,10,-48,0,-48,-30r0,-80r-21,7r0,-26r21,-7v0,-34,2,-98,-4,-120r28,-6v4,14,4,88,4,117r27,-10r0,26r-27,9r0,84v-1,16,4,20,14,17"},"\u00f8":{"d":"151,-161v43,49,28,167,-54,167v-15,0,-29,-4,-40,-11r-17,29r-17,-11r18,-31v-14,-16,-21,-41,-21,-71v0,-74,54,-113,115,-85r18,-29r17,10xm122,-152v-40,-23,-72,7,-72,58v0,19,3,37,7,49xm70,-26v38,24,72,-4,72,-57v0,-23,-2,-39,-7,-51","w":194},"\u0153":{"d":"157,-153v44,-59,144,-30,127,68r-112,0v-9,64,59,84,97,49r11,18v-30,30,-101,29,-121,-7v-46,61,-147,28,-139,-64v-10,-91,96,-122,137,-64xm254,-106v0,-36,-10,-56,-41,-56v-26,0,-40,19,-41,56r82,0xm98,-17v33,0,44,-27,44,-66v0,-46,-11,-77,-46,-77v-36,0,-47,26,-46,66v1,45,8,77,48,77","w":302},"\u00df":{"d":"32,-179v-3,-49,25,-73,68,-76v64,-5,84,80,34,98v-14,5,-25,6,-25,14v0,7,25,13,52,29v48,30,22,118,-43,118v-14,0,-27,-2,-35,-6r8,-19v30,15,67,-7,65,-41v8,-48,-75,-45,-73,-79v1,-34,52,-22,51,-61v0,-19,-14,-32,-36,-32v-23,0,-38,15,-38,51v0,60,5,130,-4,183r-27,0v7,-44,1,-108,3,-158r-26,0r0,-21r26,0","w":204},"\u0178":{"d":"147,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,9,-19,19,-19v10,0,18,9,18,19xm73,-281v0,10,-9,19,-19,19v-10,0,-18,-9,-18,-19v0,-10,8,-19,18,-19v10,0,19,9,19,19xm187,-247r-80,151r0,96r-31,0r0,-98r-80,-149r37,0r59,122r61,-122r34,0","w":183},"\u2122":{"d":"321,-99r-24,0r0,-124r-49,124r-17,0r-49,-124r0,124r-24,0r0,-148r38,0r44,113r44,-113r37,0r0,148xm128,-223r-47,0r0,124r-23,0r0,-124r-47,0r0,-24r117,0r0,24","w":353},"\u017e":{"d":"144,-249r-61,48r-61,-48r13,-16r50,30r48,-30xm147,-22r-13,22r-120,0r0,-22r98,-135r-90,0r0,-22r119,0r0,23r-93,134r99,0","w":161},"\u017d":{"d":"154,-309r-61,49r-61,-49r13,-16r50,31r48,-31xm168,-25r-7,25r-147,0r0,-23r122,-199r-118,0r8,-25r141,0r0,25r-118,197r119,0","w":182},"\u0161":{"d":"149,-249r-62,48r-61,-48r13,-16r50,30r49,-30xm152,-53v0,62,-90,71,-134,40r11,-20v28,20,90,28,93,-15v2,-25,-29,-30,-52,-34v-30,-6,-45,-24,-45,-49v0,-54,76,-69,118,-41r-10,21v-27,-18,-76,-21,-79,17v-2,23,29,27,50,31v32,7,48,23,48,50","w":169},"\u0160":{"d":"166,-309r-61,49r-61,-49r13,-16r50,31r48,-31xm31,-41v37,33,122,32,123,-25v2,-65,-128,-36,-128,-115v0,-74,102,-90,154,-48r-13,22v-24,-15,-39,-21,-60,-21v-31,0,-49,15,-49,40v0,48,90,44,113,75v40,53,-6,118,-74,118v-30,0,-55,-8,-79,-23","w":204},"\u00ff":{"d":"137,-224v0,10,-8,20,-18,20v-22,0,-26,-39,-1,-38v10,0,19,8,19,18xm63,-224v0,10,-9,20,-19,20v-25,0,-22,-39,0,-38v10,0,19,8,19,18xm158,-179r-62,185v-12,36,-26,60,-57,68r-9,-19v23,-7,32,-19,42,-55r-12,1v-13,-56,-38,-122,-56,-176r27,-10r37,117v6,17,9,45,12,44r46,-155r32,0","w":161},"\u00fe":{"d":"58,-158v48,-55,121,-12,121,68v0,75,-68,122,-119,74r0,85r-28,6r0,-295v0,-14,-2,-27,-5,-38r28,-5v7,27,6,75,3,105xm60,-42v34,45,89,18,89,-44v0,-41,-7,-72,-41,-72v-18,0,-34,7,-48,24r0,92","w":200},"\u00fd":{"d":"147,-238r-80,36r-10,-17r75,-47xm158,-179r-62,185v-12,36,-26,60,-57,68r-9,-19v23,-7,32,-19,42,-55r-12,1v-13,-56,-38,-122,-56,-176r27,-10r37,117v6,17,9,45,12,44r46,-155r32,0","w":161},"\u00fc":{"d":"153,-224v0,10,-8,20,-18,20v-26,0,-23,-39,0,-38v10,0,18,8,18,18xm79,-224v0,10,-9,20,-19,20v-25,0,-22,-39,0,-38v10,0,19,8,19,18xm58,-54v-2,54,65,40,79,4r0,-127r28,-5r0,131v0,23,3,31,12,39r-18,20v-12,-10,-17,-17,-20,-29v-26,40,-108,39,-108,-25r0,-132r27,-5r0,129","w":196},"\u00fb":{"d":"159,-218r-12,16r-51,-31r-48,31r-11,-16r61,-48xm58,-54v-2,54,65,40,79,4r0,-127r28,-5r0,131v0,23,3,31,12,39r-18,20v-12,-10,-17,-17,-20,-29v-26,40,-108,39,-108,-25r0,-132r27,-5r0,129","w":196},"\u00fa":{"d":"159,-239r-81,36r-9,-17r75,-47xm58,-54v-2,54,65,40,79,4r0,-127r28,-5r0,131v0,23,3,31,12,39r-18,20v-12,-10,-17,-17,-20,-29v-26,40,-108,39,-108,-25r0,-132r27,-5r0,129","w":196},"\u00f9":{"d":"141,-220r-9,17r-81,-36r16,-28xm58,-54v-2,54,65,40,79,4r0,-127r28,-5r0,131v0,23,3,31,12,39r-18,20v-12,-10,-17,-17,-20,-29v-26,40,-108,39,-108,-25r0,-132r27,-5r0,129","w":196},"\u00f7":{"d":"133,-170v0,14,-11,25,-24,25v-13,0,-24,-11,-24,-24v0,-14,10,-25,24,-25v13,0,24,11,24,24xm198,-85r-180,0r0,-23r180,0r0,23xm133,-20v0,14,-11,24,-25,24v-13,0,-23,-11,-23,-24v0,-14,10,-24,24,-24v13,0,24,11,24,24","w":216},"\u00f6":{"d":"152,-224v0,10,-8,20,-18,20v-26,0,-23,-39,0,-38v10,0,18,8,18,18xm77,-224v0,10,-8,20,-18,20v-26,0,-23,-39,0,-38v10,0,18,8,18,18xm96,-185v56,0,77,39,78,98v0,60,-32,92,-77,92v-49,0,-77,-37,-77,-96v0,-58,29,-94,76,-94xm98,-19v33,0,44,-27,44,-66v0,-46,-11,-77,-46,-77v-35,0,-47,27,-46,67v1,45,9,76,48,76","w":194},"\u00f5":{"d":"160,-236v-12,15,-22,23,-43,23v-28,0,-52,-27,-71,0r-10,-16v12,-15,22,-23,43,-23v28,0,52,27,71,0xm96,-185v56,0,77,39,78,98v0,60,-32,92,-77,92v-49,0,-77,-37,-77,-96v0,-58,29,-94,76,-94xm98,-19v33,0,44,-27,44,-66v0,-46,-11,-77,-46,-77v-35,0,-47,27,-46,67v1,45,9,76,48,76","w":194},"\u00f4":{"d":"159,-218r-13,16r-50,-31r-49,31r-11,-16r61,-48xm96,-185v56,0,77,39,78,98v0,60,-32,92,-77,92v-49,0,-77,-37,-77,-96v0,-58,29,-94,76,-94xm98,-19v33,0,44,-27,44,-66v0,-46,-11,-77,-46,-77v-35,0,-47,27,-46,67v1,45,9,76,48,76","w":194},"\u00f3":{"d":"151,-239r-81,36r-9,-17r74,-47xm96,-185v56,0,77,39,78,98v0,60,-32,92,-77,92v-49,0,-77,-37,-77,-96v0,-58,29,-94,76,-94xm98,-19v33,0,44,-27,44,-66v0,-46,-11,-77,-46,-77v-35,0,-47,27,-46,67v1,45,9,76,48,76","w":194},"\u00f2":{"d":"135,-220r-9,17r-81,-36r15,-28xm96,-185v56,0,77,39,78,98v0,60,-32,92,-77,92v-49,0,-77,-37,-77,-96v0,-58,29,-94,76,-94xm98,-19v33,0,44,-27,44,-66v0,-46,-11,-77,-46,-77v-35,0,-47,27,-46,67v1,45,9,76,48,76","w":194},"\u00f1":{"d":"158,-236v-12,15,-22,23,-43,23v-28,0,-52,-27,-71,0r-10,-16v12,-15,22,-23,43,-23v28,0,52,27,71,0xm116,-183v26,0,49,17,48,47r0,136r-28,0r0,-121v3,-58,-53,-38,-76,-13r0,134r-28,0v-2,-52,5,-138,-6,-176r27,-8v0,0,6,13,6,28v19,-19,38,-27,57,-27","w":196},"\u00f0":{"d":"177,-94v0,62,-36,99,-79,99v-44,0,-76,-42,-76,-88v0,-61,59,-102,114,-76v-8,-23,-23,-43,-46,-58r-18,21r-19,-13r18,-20v-13,-7,-28,-12,-45,-17r14,-17v17,4,33,10,47,16r15,-18r19,13r-14,16v49,31,70,79,70,142xm100,-18v46,0,53,-73,42,-116v-10,-6,-28,-11,-45,-11v-27,0,-44,29,-44,63v0,34,19,64,47,64","w":198},"\u00ef":{"d":"99,-224v0,10,-8,20,-18,20v-26,0,-23,-39,0,-38v10,0,18,8,18,18xm32,-224v0,10,-8,20,-18,20v-26,0,-23,-39,0,-38v10,0,18,8,18,18xm62,0r-30,0r0,-179r30,-4r0,183"},"\u00ee":{"d":"109,-218r-13,16r-50,-31r-49,31r-11,-16r61,-48xm62,0r-30,0r0,-179r30,-4r0,183"},"\u00ed":{"d":"101,-239r-80,36r-10,-17r75,-47xm62,0r-30,0r0,-179r30,-4r0,183"},"\u00ec":{"d":"83,-220r-9,17r-81,-36r16,-28xm62,0r-30,0r0,-179r30,-4r0,183"},"\u00eb":{"d":"152,-224v0,10,-9,20,-19,20v-26,0,-23,-39,0,-38v10,0,19,8,19,18xm77,-224v0,10,-8,20,-18,20v-22,0,-26,-39,-1,-38v10,0,19,8,19,18xm97,-184v51,0,71,32,69,99r-112,0v-9,64,59,84,97,49r11,18v-56,47,-140,16,-140,-73v0,-52,28,-93,75,-93xm136,-106v0,-36,-10,-56,-41,-56v-26,0,-40,19,-41,56r82,0","w":183},"\u00ea":{"d":"158,-218r-13,16r-50,-31r-49,31r-11,-16r61,-48xm97,-184v51,0,71,32,69,99r-112,0v-9,64,59,84,97,49r11,18v-56,47,-140,16,-140,-73v0,-52,28,-93,75,-93xm136,-106v0,-36,-10,-56,-41,-56v-26,0,-40,19,-41,56r82,0","w":183},"\u00e9":{"d":"146,-239r-81,36r-9,-17r74,-47xm97,-184v51,0,71,32,69,99r-112,0v-9,64,59,84,97,49r11,18v-56,47,-140,16,-140,-73v0,-52,28,-93,75,-93xm136,-106v0,-36,-10,-56,-41,-56v-26,0,-40,19,-41,56r82,0","w":183},"\u00e8":{"d":"136,-220r-9,17r-81,-36r16,-28xm97,-184v51,0,71,32,69,99r-112,0v-9,64,59,84,97,49r11,18v-56,47,-140,16,-140,-73v0,-52,28,-93,75,-93xm136,-106v0,-36,-10,-56,-41,-56v-26,0,-40,19,-41,56r82,0","w":183},"\u00e7":{"d":"131,-145v-43,-36,-86,3,-78,64v-5,62,51,82,82,43r16,18v-16,17,-32,24,-53,24r-3,11v37,8,28,56,-12,56v-11,0,-22,-5,-29,-9r7,-17v13,7,31,11,35,-5v0,-15,-22,-5,-26,-13r7,-25v-37,-9,-55,-43,-55,-89v0,-82,72,-121,124,-78","w":165},"\u00e5":{"d":"136,-237v0,21,-16,38,-37,38v-21,0,-39,-17,-39,-38v0,-21,17,-38,38,-38v21,0,38,17,38,38xm26,-160v48,-35,141,-40,129,44v2,34,-11,95,13,103r-14,20v-12,-4,-22,-13,-25,-26v-17,17,-31,24,-52,24v-44,0,-57,-27,-57,-51v-1,-44,43,-68,107,-65v14,-68,-60,-52,-87,-29xm120,-237v0,-12,-10,-22,-22,-22v-11,0,-21,10,-21,22v0,12,10,21,22,21v11,0,21,-9,21,-21xm127,-91v-44,-5,-76,11,-76,42v0,47,64,38,75,5","w":186},"\u00e4":{"d":"153,-224v0,10,-9,20,-19,20v-26,0,-23,-39,0,-38v10,0,19,8,19,18xm78,-224v0,10,-8,20,-18,20v-22,0,-26,-39,-1,-38v10,0,19,8,19,18xm26,-160v48,-35,141,-40,129,44v2,34,-11,95,13,103r-14,20v-12,-4,-22,-13,-25,-26v-17,17,-31,24,-52,24v-44,0,-57,-27,-57,-51v-1,-44,43,-68,107,-65v14,-68,-60,-52,-87,-29xm127,-91v-44,-5,-76,11,-76,42v0,47,64,38,75,5","w":186},"\u00e3":{"d":"157,-236v-12,15,-23,23,-44,23v-28,0,-52,-27,-71,0r-10,-16v12,-15,23,-23,44,-23v28,0,51,27,71,0xm26,-160v48,-35,141,-40,129,44v2,34,-11,95,13,103r-14,20v-12,-4,-22,-13,-25,-26v-17,17,-31,24,-52,24v-44,0,-57,-27,-57,-51v-1,-44,43,-68,107,-65v14,-68,-60,-52,-87,-29xm127,-91v-44,-5,-76,11,-76,42v0,47,64,38,75,5","w":186},"\u00e2":{"d":"156,-218r-13,16r-50,-31r-49,31r-11,-16r61,-48xm26,-160v48,-35,141,-40,129,44v2,34,-11,95,13,103r-14,20v-12,-4,-22,-13,-25,-26v-17,17,-31,24,-52,24v-44,0,-57,-27,-57,-51v-1,-44,43,-68,107,-65v14,-68,-60,-52,-87,-29xm127,-91v-44,-5,-76,11,-76,42v0,47,64,38,75,5","w":186},"\u00e1":{"d":"146,-239r-80,36r-10,-17r75,-47xm26,-160v48,-35,141,-40,129,44v2,34,-11,95,13,103r-14,20v-12,-4,-22,-13,-25,-26v-17,17,-31,24,-52,24v-44,0,-57,-27,-57,-51v-1,-44,43,-68,107,-65v14,-68,-60,-52,-87,-29xm127,-91v-44,-5,-76,11,-76,42v0,47,64,38,75,5","w":186},"\u00e0":{"d":"134,-220r-9,17r-81,-36r15,-28xm26,-160v48,-35,141,-40,129,44v2,34,-11,95,13,103r-14,20v-12,-4,-22,-13,-25,-26v-17,17,-31,24,-52,24v-44,0,-57,-27,-57,-51v-1,-44,43,-68,107,-65v14,-68,-60,-52,-87,-29xm127,-91v-44,-5,-76,11,-76,42v0,47,64,38,75,5","w":186},"\u00de":{"d":"61,-200v72,-7,125,11,125,70v0,65,-52,87,-125,79r0,51r-29,0r0,-247r29,0r0,47xm61,-76v51,4,93,-2,93,-48v0,-49,-40,-54,-93,-51r0,99","w":193},"\u00dd":{"d":"145,-297r-80,36r-10,-17r75,-47xm187,-247r-80,151r0,96r-31,0r0,-98r-80,-149r37,0r59,122r61,-122r34,0","w":183},"\u00dc":{"d":"168,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,8,-19,18,-19v10,0,19,9,19,19xm94,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,8,-19,18,-19v10,0,19,9,19,19xm112,-21v38,2,53,-17,53,-54r0,-172r29,0r0,176v2,59,-29,73,-83,75v-52,2,-81,-25,-80,-74r0,-177r29,0r0,166v1,41,5,58,52,60","w":225},"\u00db":{"d":"174,-275r-13,15r-50,-30r-49,30r-11,-15r61,-49xm112,-21v38,2,53,-17,53,-54r0,-172r29,0r0,176v2,59,-29,73,-83,75v-52,2,-81,-25,-80,-74r0,-177r29,0r0,166v1,41,5,58,52,60","w":225},"\u00da":{"d":"157,-297r-80,36r-10,-17r75,-47xm112,-21v38,2,53,-17,53,-54r0,-172r29,0r0,176v2,59,-29,73,-83,75v-52,2,-81,-25,-80,-74r0,-177r29,0r0,166v1,41,5,58,52,60","w":225},"\u00d9":{"d":"144,-278r-9,17r-81,-36r15,-28xm112,-21v38,2,53,-17,53,-54r0,-172r29,0r0,176v2,59,-29,73,-83,75v-52,2,-81,-25,-80,-74r0,-177r29,0r0,166v1,41,5,58,52,60","w":225},"\u00d7":{"d":"160,-45r-19,19r-45,-46r-45,46r-19,-19r46,-45r-46,-45r19,-19r45,46r45,-46r19,19r-46,45","w":192},"\u00d6":{"d":"175,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,9,-19,19,-19v10,0,18,9,18,19xm101,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,8,-19,18,-19v10,0,19,9,19,19xm120,-251v82,0,97,52,100,131v3,74,-33,125,-99,125v-68,0,-99,-56,-99,-130v0,-78,37,-126,98,-126xm123,-18v50,0,64,-32,64,-97v0,-69,-8,-113,-67,-113v-50,0,-66,39,-66,97v0,67,13,113,69,113","w":241},"\u00d5":{"d":"183,-294v-12,15,-23,23,-44,23v-28,0,-51,-26,-70,1r-10,-17v12,-15,22,-22,43,-22v28,0,52,26,71,-1xm120,-251v82,0,97,52,100,131v3,74,-33,125,-99,125v-68,0,-99,-56,-99,-130v0,-78,37,-126,98,-126xm123,-18v50,0,64,-32,64,-97v0,-69,-8,-113,-67,-113v-50,0,-66,39,-66,97v0,67,13,113,69,113","w":241},"\u00d4":{"d":"183,-275r-13,15r-50,-30r-49,30r-11,-15r61,-49xm120,-251v82,0,97,52,100,131v3,74,-33,125,-99,125v-68,0,-99,-56,-99,-130v0,-78,37,-126,98,-126xm123,-18v50,0,64,-32,64,-97v0,-69,-8,-113,-67,-113v-50,0,-66,39,-66,97v0,67,13,113,69,113","w":241},"\u00d3":{"d":"181,-297r-81,36r-9,-17r74,-47xm120,-251v82,0,97,52,100,131v3,74,-33,125,-99,125v-68,0,-99,-56,-99,-130v0,-78,37,-126,98,-126xm123,-18v50,0,64,-32,64,-97v0,-69,-8,-113,-67,-113v-50,0,-66,39,-66,97v0,67,13,113,69,113","w":241},"\u00d2":{"d":"158,-278r-9,17r-81,-36r16,-28xm120,-251v82,0,97,52,100,131v3,74,-33,125,-99,125v-68,0,-99,-56,-99,-130v0,-78,37,-126,98,-126xm123,-18v50,0,64,-32,64,-97v0,-69,-8,-113,-67,-113v-50,0,-66,39,-66,97v0,67,13,113,69,113","w":241},"\u00d1":{"d":"175,-294v-12,15,-23,23,-44,23v-28,0,-51,-26,-70,1r-10,-17v12,-15,22,-22,43,-22v28,0,52,26,71,-1xm197,0r-31,0r-80,-151v-16,-30,-28,-60,-28,-60v5,42,5,154,5,211r-31,0r0,-247r35,0r82,158v13,24,23,52,23,52v-5,-39,-5,-155,-5,-210r30,0r0,247","w":228},"\u00d0":{"d":"82,-247v85,-5,120,44,121,124v2,107,-63,133,-171,123r0,-116r-30,0r0,-21r30,0r0,-110r50,0xm154,-50v35,-62,21,-182,-63,-173r-29,0r0,86r57,0r-8,21r-49,0r0,92v41,0,75,5,92,-26","w":224},"\u00cf":{"d":"103,-281v0,10,-9,19,-19,19v-10,0,-19,-9,-19,-19v0,-10,9,-19,19,-19v10,0,19,9,19,19xm28,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,8,-19,18,-19v10,0,19,9,19,19xm61,0r-29,0r0,-247r29,0r0,247"},"\u00ce":{"d":"108,-275r-13,15r-50,-30r-48,30r-11,-15r61,-49xm61,0r-29,0r0,-247r29,0r0,247"},"\u00cd":{"d":"112,-297r-80,36r-10,-17r75,-47xm61,0r-29,0r0,-247r29,0r0,247"},"\u00cc":{"d":"73,-278r-9,17r-81,-36r16,-28xm61,0r-29,0r0,-247r29,0r0,247"},"\u00cb":{"d":"157,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,8,-19,18,-19v10,0,19,9,19,19xm82,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,9,-19,19,-19v10,0,18,9,18,19xm171,0r-139,0r0,-247r135,0r-4,25r-101,0r0,81r85,0r0,25r-85,0r0,90r109,0r0,26","w":183},"\u00ca":{"d":"163,-275r-13,15r-50,-30r-49,30r-11,-15r61,-49xm171,0r-139,0r0,-247r135,0r-4,25r-101,0r0,81r85,0r0,25r-85,0r0,90r109,0r0,26","w":183},"\u00c9":{"d":"152,-297r-81,36r-9,-17r74,-47xm171,0r-139,0r0,-247r135,0r-4,25r-101,0r0,81r85,0r0,25r-85,0r0,90r109,0r0,26","w":183},"\u00c8":{"d":"141,-278r-9,17r-81,-36r16,-28xm171,0r-139,0r0,-247r135,0r-4,25r-101,0r0,81r85,0r0,25r-85,0r0,90r109,0r0,26","w":183},"\u00c7":{"d":"54,-118v0,81,63,123,122,82r16,20v-19,13,-44,20,-68,20r-3,11v18,3,24,13,24,26v0,26,-45,39,-65,21r7,-17v13,7,33,11,35,-5v2,-15,-22,-5,-26,-13r7,-25v-50,-10,-81,-64,-81,-125v0,-101,90,-160,166,-107r-16,19v-63,-42,-118,9,-118,93","w":202},"\u00c5":{"d":"141,-295v0,21,-17,38,-38,38v-21,0,-38,-17,-38,-38v0,-21,17,-38,38,-38v21,0,38,17,38,38xm204,0r-33,0r-23,-76r-93,0r-23,76r-30,0r82,-247r39,0xm125,-295v0,-12,-11,-21,-23,-21v-11,0,-20,9,-20,21v0,12,9,22,21,22v11,0,22,-10,22,-22xm140,-100r-38,-121r-39,121r77,0","w":206},"\u00c4":{"d":"160,-281v0,10,-9,19,-19,19v-10,0,-19,-9,-19,-19v0,-10,9,-19,19,-19v10,0,19,9,19,19xm85,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,9,-19,19,-19v10,0,18,9,18,19xm204,0r-33,0r-23,-76r-93,0r-23,76r-30,0r82,-247r39,0xm140,-100r-38,-121r-39,121r77,0","w":206},"\u00c3":{"d":"164,-294v-12,15,-23,23,-44,23v-28,0,-51,-26,-70,1r-10,-17v12,-15,22,-22,43,-22v28,0,52,26,71,-1xm204,0r-33,0r-23,-76r-93,0r-23,76r-30,0r82,-247r39,0xm140,-100r-38,-121r-39,121r77,0","w":206},"\u00c2":{"d":"165,-275r-13,15r-50,-30r-49,30r-11,-15r61,-49xm204,0r-33,0r-23,-76r-93,0r-23,76r-30,0r82,-247r39,0xm140,-100r-38,-121r-39,121r77,0","w":206},"\u00c1":{"d":"162,-297r-81,36r-9,-17r75,-47xm204,0r-33,0r-23,-76r-93,0r-23,76r-30,0r82,-247r39,0xm140,-100r-38,-121r-39,121r77,0","w":206},"\u00c0":{"d":"135,-278r-10,17r-80,-36r15,-28xm204,0r-33,0r-23,-76r-93,0r-23,76r-30,0r82,-247r39,0xm140,-100r-38,-121r-39,121r77,0","w":206},"\u00b1":{"d":"152,-106r-54,0r0,51r-26,0r0,-51r-54,0r0,-25r54,0r0,-48r26,0r0,48r54,0r0,25xm151,-13r-132,0r0,-26r132,0r0,26","w":169},"\u00b0":{"d":"130,-185v0,33,-18,59,-58,59v-36,0,-58,-24,-58,-62v0,-38,22,-61,58,-61v36,0,58,23,58,64xm106,-184v0,-28,-7,-45,-34,-45v-23,0,-33,13,-33,39v0,32,11,45,34,45v20,0,33,-12,33,-39","w":144},"\u00ae":{"d":"289,-127v0,76,-60,133,-133,133v-73,0,-134,-57,-134,-133v0,-76,61,-134,134,-134v73,0,133,58,133,134xm266,-127v0,-65,-49,-115,-110,-115v-62,0,-111,50,-111,115v0,65,49,114,111,114v61,0,110,-49,110,-114xm114,-203v46,-1,91,-3,90,42v0,23,-14,42,-39,41v19,15,33,48,47,66r-26,0v-15,-24,-26,-57,-51,-66r0,66r-21,0r0,-149xm135,-134v28,1,48,-2,48,-27v0,-23,-22,-27,-48,-25r0,52","w":311},"\u00ac":{"d":"158,-28r-26,0r0,-50r-114,0r0,-26r140,0r0,76","w":176},"\u00a9":{"d":"289,-127v0,76,-60,133,-133,133v-73,0,-134,-57,-134,-133v0,-76,61,-134,134,-134v73,0,133,58,133,134xm266,-127v0,-65,-49,-115,-110,-115v-62,0,-111,50,-111,115v0,65,49,114,111,114v61,0,110,-49,110,-114xm121,-126v-5,49,36,73,70,50r10,14v-47,32,-103,-4,-103,-63v0,-59,54,-100,100,-67r-10,14v-35,-24,-72,5,-67,52","w":311},"\u00a6":{"d":"56,-125r-24,0r0,-147r24,0r0,147xm56,75r-24,0r0,-148r24,0r0,148","w":88},"\u00b3":{"d":"40,-180v27,0,44,2,44,-18v0,-27,-44,-21,-58,-5r-12,-14v24,-28,95,-28,95,17v0,13,-7,24,-19,30v14,6,23,17,23,32v-2,37,-45,56,-91,51r-6,-19v33,7,69,-3,71,-34v-3,-20,-18,-21,-47,-21r0,-19","w":127},"\u00b2":{"d":"17,-108v18,-10,70,-66,65,-85v-1,-33,-41,-24,-56,-9r-12,-13v33,-34,95,-29,95,19v0,36,-35,61,-56,83v17,-2,39,0,58,-1r-6,20r-88,0r0,-14","w":125},"\u00b9":{"d":"99,-94r-68,0r0,-19r22,0r0,-93v-10,6,-21,11,-32,16r-7,-15v21,-10,30,-32,63,-30r0,122r22,0r0,19","w":113},"\u00be":{"d":"339,-26r-17,0r0,26r-24,7r0,-33r-64,0r0,-16r53,-99r27,0v-9,18,-35,66,-53,96v15,-2,42,9,38,-14r3,-39r20,-6v1,19,-2,42,1,59r16,0r0,19xm294,-275r-189,330r-24,0r190,-330r23,0xm40,-180v27,0,44,2,44,-18v0,-27,-44,-21,-58,-5r-12,-14v24,-28,95,-28,95,17v0,13,-7,24,-19,30v14,6,23,17,23,32v-2,37,-45,56,-91,51r-6,-19v33,7,69,-3,71,-34v-3,-20,-18,-21,-47,-21r0,-19","w":353},"\u00bd":{"d":"221,-14v18,-11,71,-66,66,-85v-1,-33,-41,-25,-57,-10r-11,-12v32,-36,95,-29,95,19v0,36,-36,60,-57,82r58,0r-5,20r-89,0r0,-14xm273,-275r-190,330r-24,0r190,-330r24,0xm99,-94r-68,0r0,-19r22,0r0,-93v-10,6,-21,11,-32,16r-7,-15v21,-10,30,-32,63,-30r0,122r22,0r0,19","w":329},"\u00bc":{"d":"324,-26r-18,0v2,7,1,17,1,26r-24,7r0,-33r-64,0r0,-16r52,-99r27,0v-9,18,-34,66,-52,96v15,-3,42,10,37,-14r3,-39r21,-6v1,18,-3,46,1,59r16,0r0,19xm279,-275r-189,330r-24,0r190,-330r23,0xm99,-94r-68,0r0,-19r22,0r0,-93v-10,6,-21,11,-32,16r-7,-15v21,-10,30,-32,63,-30r0,122r22,0r0,19","w":338},"\u00a0":{"w":82}}});
/*!
 * The following copyright notice may not be removed under any circumstances.
 *
 * Copyright:
 * < info@fontfont.de > CopDomainyright Erik Spiekermann, 1991, 93, 98. Published by
 * FontShop International for  FontFont Release 23, Meta is a trademark of FSI
 * Fonts and Software GmbH.
 */
Cufon.registerFont({"w":201,"face":{"font-family":"Meta","font-weight":700,"font-stretch":"normal","units-per-em":"360","panose-1":"2 0 8 3 0 0 0 0 0 0","ascent":"288","descent":"-72","x-height":"4","bbox":"-16 -339 346 81","underline-thickness":"7.2","underline-position":"-51.12","stemh":"7","stemv":"53","unicode-range":"U+0020-U+2122"},"glyphs":{" ":{"w":81},"!":{"d":"81,-256r-10,176r-36,0r-11,-167xm83,-25v0,17,-13,30,-30,30v-16,0,-30,-13,-30,-30v0,-17,13,-30,30,-30v16,0,30,13,30,30","w":106},"\"":{"d":"152,-153r-45,0r0,-102r45,0r0,102xm69,-153r-46,0r0,-102r46,0r0,102","w":175},"#":{"d":"192,-150r-35,0r-6,45r30,0r0,33r-34,0r-11,72r-34,0r10,-72r-36,0r-10,72r-35,0r10,-72r-30,0r0,-33r34,0r6,-45r-30,0r0,-33r35,0r10,-72r35,0r-10,72r35,0r10,-72r35,0r-10,72r31,0r0,33xm122,-150r-36,0r-6,45r36,0","w":202},"$":{"d":"199,-79v0,46,-34,79,-87,84r0,29r-31,0r0,-29v-24,-2,-49,-10,-70,-22r19,-40v33,23,112,37,112,-14v0,-45,-93,-35,-110,-71v-25,-53,6,-111,65,-115r0,-26r31,0r0,26v25,3,49,11,67,24r-24,36v-23,-14,-39,-19,-58,-19v-21,0,-35,12,-35,29v0,22,38,28,58,34v41,12,63,37,63,74","w":210},"%":{"d":"230,-121v36,0,63,24,62,62v0,39,-22,63,-62,63v-37,0,-61,-24,-61,-62v0,-37,24,-63,61,-63xm234,-250r-131,250r-34,0r131,-250r34,0xm72,-254v36,0,63,24,62,62v0,39,-22,63,-62,63v-37,0,-61,-24,-61,-62v0,-37,24,-63,61,-63xm208,-59v0,24,3,36,22,36v15,0,22,-11,22,-37v0,-21,-5,-34,-23,-34v-18,0,-21,14,-21,35xm50,-192v0,24,3,36,22,36v15,0,22,-11,22,-37v0,-22,-6,-34,-23,-34v-17,0,-21,14,-21,35","w":302},"&":{"d":"59,-125v-52,-32,-29,-115,43,-115v59,0,92,50,61,92v-7,8,-20,15,-35,24r42,39v3,-10,3,-17,3,-37v12,2,32,-4,40,2v0,27,-3,49,-11,67r54,53r-67,0r-15,-15v-16,14,-37,20,-69,20v-98,0,-122,-99,-46,-130xm101,-148v27,-10,35,-54,2,-58v-34,4,-26,41,-2,58xm144,-42r-59,-57v-32,17,-23,69,21,69v17,0,30,-4,38,-12","w":253},"\u2019":{"d":"37,-188v0,-13,-29,-18,-24,-37v0,-17,14,-31,32,-31v61,0,36,101,-15,108r-19,-20v15,-4,26,-11,26,-20","w":93},"(":{"d":"63,-117v1,67,9,129,57,150r-13,28v-101,-22,-123,-224,-53,-305v14,-15,32,-28,52,-37r13,28v-42,26,-57,68,-56,136","w":112},")":{"d":"5,-282v102,21,122,226,53,306v-14,16,-32,27,-53,36r-12,-28v41,-26,57,-68,56,-137v-1,-67,-8,-127,-56,-148","w":111},"*":{"d":"162,-186r-47,15r30,41r-30,22r-30,-42r-29,40r-29,-22r30,-39r-48,-17r12,-34r47,17r0,-50r36,0r0,50r48,-16","w":171},"+":{"d":"212,-86r-76,0r0,76r-46,0r0,-76r-76,0r0,-46r76,0r0,-76r46,0r0,76r76,0r0,46","w":226},",":{"d":"40,12v-1,-13,-28,-18,-23,-37v0,-17,14,-31,31,-31v61,0,36,101,-15,108r-19,-20v16,-4,26,-11,26,-20","w":102},"-":{"d":"101,-78r-87,0r0,-42r87,0r0,42","w":115},".":{"d":"81,-26v0,18,-14,32,-31,32v-18,0,-32,-14,-32,-32v0,-17,14,-32,31,-32v18,0,32,15,32,32","w":99},"\/":{"d":"143,-275r-97,330r-32,0r97,-330r32,0","w":156},"0":{"d":"186,-120v0,76,-35,125,-86,125v-53,0,-85,-49,-85,-124v0,-76,35,-125,86,-125v53,0,85,49,85,124xm132,-118v0,-73,-13,-90,-31,-90v-24,0,-32,35,-32,87v0,73,13,91,31,91v24,0,32,-36,32,-88"},"1":{"d":"162,0r-121,0r0,-39r43,0r0,-146v-13,8,-32,18,-48,23r-13,-26r75,-52r33,0r0,201r31,0r0,39"},"2":{"d":"19,-34v26,-25,105,-98,100,-135v-7,-51,-51,-34,-81,-8r-26,-31v43,-50,163,-53,161,33v-2,52,-60,103,-98,136v32,-2,74,-1,109,-1r-10,40r-155,0r0,-34"},"3":{"d":"126,-77v0,-32,-31,-34,-68,-32r0,-40v30,4,65,1,65,-27v0,-41,-71,-25,-84,-7r-25,-30v45,-46,162,-41,163,32v0,26,-16,47,-37,53v27,9,43,30,43,55v0,58,-76,93,-157,82r-12,-33v54,10,112,-12,112,-53"},"4":{"d":"190,-45r-28,-1v3,11,2,39,2,55r-46,5r1,-60v-32,2,-73,0,-107,1r0,-33r70,-163r49,0r-51,122v-6,14,-12,26,-17,33r57,0r6,-97r38,-8r-1,105r27,0r0,41"},"5":{"d":"177,-81v0,61,-67,104,-141,89r-10,-35v48,16,101,-6,99,-48v-2,-46,-50,-43,-92,-28r12,-136r122,0r-7,41r-70,0r-5,49v54,-7,92,22,92,68"},"6":{"d":"188,-77v0,46,-36,82,-84,82v-53,0,-91,-42,-91,-101v-1,-83,73,-143,143,-163r10,35v-42,14,-80,39,-94,83v48,-33,116,6,116,64xm137,-76v0,-41,-41,-47,-70,-26v-5,35,6,70,35,70v22,0,35,-17,35,-44"},"7":{"d":"186,-239r-8,42v-37,56,-70,116,-86,200r-53,14v20,-86,51,-155,91,-214v-34,3,-73,0,-109,1r10,-43r155,0"},"8":{"d":"193,-66v1,47,-50,73,-96,73v-43,0,-89,-19,-89,-69v0,-27,17,-52,42,-61v-66,-32,-32,-121,51,-121v86,0,114,94,37,116v28,10,55,28,55,62xm101,-147v30,-7,46,-63,-3,-61v-20,0,-34,11,-34,27v0,20,22,27,37,34xm102,-28v36,0,49,-41,23,-57v-9,-6,-23,-13,-40,-19v-35,17,-29,76,17,76"},"9":{"d":"189,-145v0,80,-71,143,-136,166r-26,-30v39,-10,84,-47,95,-77v-53,24,-108,-17,-107,-73v0,-49,38,-85,88,-85v54,0,86,38,86,99xm104,-118v20,0,32,-15,32,-40v0,-30,-12,-49,-34,-49v-21,0,-34,18,-34,46v0,26,14,43,36,43"},":":{"d":"84,-132v0,17,-14,30,-31,30v-17,0,-31,-13,-31,-30v0,-17,14,-32,31,-32v17,0,31,15,31,32xm84,-24v0,17,-14,30,-31,30v-17,0,-31,-13,-31,-30v0,-18,14,-33,31,-33v17,0,31,15,31,33","w":105},";":{"d":"87,-133v0,17,-14,31,-31,31v-17,0,-31,-13,-31,-30v0,-17,13,-32,30,-32v17,0,32,14,32,31xm47,12v0,-12,-28,-19,-23,-36v0,-18,13,-32,31,-32v61,0,36,102,-15,108r-18,-20v15,-4,25,-11,25,-20","w":113},"<":{"d":"132,-28r-38,32r-87,-112r87,-112r38,34r-61,78","w":146},"=":{"d":"212,-121r-198,0r0,-45r198,0r0,45xm212,-52r-198,0r0,-45r198,0r0,45","w":226},">":{"d":"139,-108r-87,112r-38,-32r61,-80r-61,-78r38,-34","w":146},"?":{"d":"151,-194v0,33,-20,46,-33,55v-26,18,-30,33,-27,59r-42,0v-7,-35,0,-57,30,-78v10,-7,24,-14,24,-29v1,-38,-60,-23,-68,-8r-22,-31v9,-9,32,-28,69,-28v37,0,69,22,69,60xm105,-25v0,17,-13,30,-30,30v-16,0,-30,-13,-30,-30v0,-17,13,-30,30,-30v16,0,30,13,30,30","w":170},"@":{"d":"306,-99v0,63,-37,106,-81,106v-36,0,-41,-16,-42,-33v-26,38,-101,44,-101,-25v0,-80,80,-144,153,-99v-10,32,-15,65,-22,97v-6,28,-3,32,13,32v22,0,38,-32,38,-78v0,-57,-41,-95,-101,-95v-57,0,-106,55,-106,122v0,87,76,121,152,96r6,30v-100,33,-201,-19,-201,-126v0,-85,63,-155,149,-155v80,0,143,52,143,128xm194,-134v-50,-13,-73,40,-72,84v0,14,4,23,15,23v15,0,38,-16,44,-45","w":320},"A":{"d":"212,0r-54,0r-17,-59r-74,0r-17,59r-53,0r82,-251r55,0xm129,-101v-2,-2,-22,-83,-24,-95r-25,95r49,0","w":209},"B":{"d":"110,-250v83,-14,110,96,42,117v71,14,66,131,-16,132r-111,1r0,-250r85,0xm75,-150v34,2,64,2,64,-29v0,-29,-31,-30,-64,-28r0,57xm76,-41v37,2,69,0,69,-35v0,-34,-32,-35,-69,-33r0,68","w":216},"C":{"d":"71,-130v-9,81,47,118,102,79r23,32v-20,16,-42,23,-70,23v-70,1,-112,-54,-112,-124v0,-105,96,-171,176,-116r-22,34v-51,-35,-105,3,-97,72","w":203},"D":{"d":"76,-250v92,-8,132,41,132,126v0,75,-38,133,-122,124r-61,0r0,-250r51,0xm152,-120v1,-58,-12,-99,-76,-91r0,170v56,5,75,-13,76,-79","w":222},"E":{"d":"171,0r-146,0r0,-250r143,0r-7,41r-85,0r0,58r71,0r0,41r-71,0r0,67r95,0r0,43","w":178},"F":{"d":"161,-250r-6,40r-79,0r0,58r63,0r0,41r-63,0r0,111r-51,0r0,-250r136,0","w":157},"G":{"d":"71,-120v0,67,31,97,86,79r0,-57r-38,0r-6,-41r97,0r0,120v-26,15,-54,22,-84,22v-71,1,-113,-53,-112,-126v0,-75,39,-129,113,-131v30,0,58,10,80,29r-27,31v-16,-13,-33,-19,-52,-19v-49,1,-57,40,-57,93","w":231},"H":{"d":"198,0r-51,0r0,-112r-72,0r0,112r-50,0r0,-250r50,0r0,97r72,0r0,-97r51,0r0,250","w":223},"I":{"d":"78,0r-53,0r0,-250r53,0r0,250","w":102},"J":{"d":"-7,33v27,-21,34,-24,34,-76r0,-207r51,0r0,201v7,74,-25,88,-62,108","w":103},"K":{"d":"219,0r-66,0r-76,-131r0,131r-52,0r0,-250r52,0r0,114r71,-114r62,0r-80,116","w":211},"L":{"d":"166,-42r-9,42r-132,0r0,-250r52,0r0,208r89,0","w":168},"M":{"d":"276,0r-49,0r-11,-175v-13,60,-33,117,-49,175r-43,0r-46,-176v0,61,-7,118,-10,176r-50,0r23,-250r65,0r33,125v5,18,6,27,8,40v11,-56,29,-111,43,-165r64,0","w":294},"N":{"d":"199,0r-52,0r-77,-178r4,178r-49,0r0,-250r56,0v24,52,60,117,75,171v-6,-55,-4,-113,-5,-171r48,0r0,250","w":224},"O":{"d":"14,-124v0,-74,35,-129,109,-129v67,0,107,49,107,127v0,77,-31,127,-105,130v-75,3,-111,-57,-111,-128xm71,-124v1,59,6,89,52,89v35,0,49,-26,49,-90v0,-54,0,-82,-50,-90v-43,3,-52,41,-51,91","w":244},"P":{"d":"91,-250v79,-2,106,21,106,77v0,60,-44,88,-121,81r0,92r-51,0r0,-250r66,0xm76,-133v39,2,65,-1,65,-39v0,-37,-28,-41,-65,-38r0,77","w":203},"Q":{"d":"181,-12v19,11,47,30,76,22v-13,17,-1,40,-36,37v-45,-3,-56,-32,-97,-43v-74,3,-110,-57,-110,-128v0,-74,35,-128,109,-129v67,0,107,49,107,127v0,54,-19,94,-49,114xm71,-124v1,59,6,89,52,89v35,0,49,-26,49,-90v0,-54,0,-82,-50,-90v-43,3,-52,41,-51,91","w":244},"R":{"d":"207,0r-60,0v-21,-30,-50,-108,-72,-104r0,104r-50,0r0,-250r93,0v44,0,74,29,74,73v0,37,-25,68,-56,69v21,16,66,103,71,108xm75,-142v39,2,64,-2,64,-34v0,-33,-29,-35,-64,-34r0,68","w":210},"S":{"d":"199,-79v0,84,-122,105,-188,62r19,-40v33,23,112,37,112,-14v0,-45,-93,-35,-110,-71v-27,-58,12,-116,80,-116v31,0,61,9,83,25r-24,36v-23,-14,-39,-19,-58,-19v-21,0,-35,12,-35,29v0,22,38,28,58,34v41,12,63,37,63,74","w":210},"T":{"d":"184,-250r-8,42r-60,0r0,208r-51,0r0,-208r-61,0r0,-42r180,0","w":176},"U":{"d":"114,-39v31,0,39,-15,39,-51r0,-160r51,0r0,168v0,24,1,29,-3,40v-6,20,-31,47,-85,47v-57,0,-93,-21,-92,-81r0,-174r52,0r0,164v-1,35,9,47,38,47","w":228},"V":{"d":"211,-250r-88,252r-45,0r-85,-252r55,0r53,174v14,-62,38,-116,57,-174r53,0","w":203},"W":{"d":"300,-250r-61,252r-55,0r-22,-102v-7,-33,-11,-65,-12,-72v-3,29,-24,134,-33,174r-57,0r-60,-252r53,0v10,40,35,156,35,181v3,-41,25,-134,35,-181r56,0r23,112v5,23,10,66,10,66v6,-45,24,-130,35,-178r53,0","w":299},"X":{"d":"208,0r-61,0r-45,-88r-45,88r-62,0r78,-134r-68,-116r62,0r34,67r34,-67r60,0r-65,113","w":202},"Y":{"d":"201,-250r-80,147r0,103r-52,0r0,-103r-78,-147r60,0v15,31,35,67,45,100v14,-35,30,-67,46,-100r59,0","w":192},"Z":{"d":"180,-41r-13,41r-156,0r0,-35r107,-175v-22,3,-73,2,-102,2r11,-42r150,0r0,36r-93,157v-5,9,-13,17,-13,17v29,-2,76,-1,109,-1","w":190},"[":{"d":"101,56r-76,0r0,-320r76,0r0,33r-33,0r0,255r33,0r0,32","w":108},"\\":{"d":"152,6r-40,13r-108,-280r41,-13","w":155},"]":{"d":"83,56r-76,0r0,-32r33,0r0,-255r-33,0r0,-33r76,0r0,320","w":108},"^":{"d":"198,-123r-51,0r-40,-86r-40,86r-51,0r65,-132r53,0","w":214},"_":{"d":"180,45r-180,0r0,-18r180,0r0,18","w":180},"\u2018":{"d":"57,-217v0,13,28,17,23,36v0,17,-14,31,-31,31v-60,0,-37,-101,14,-108r19,20v-16,4,-25,12,-25,21","w":93},"a":{"d":"17,-162v41,-31,155,-49,142,39v3,40,-13,85,17,103r-26,29v-11,-5,-21,-13,-26,-22v-29,37,-111,21,-111,-38v0,-46,37,-65,99,-63v4,-54,-45,-35,-75,-14xm111,-41v-2,-12,4,-32,-2,-40v-33,0,-45,6,-45,28v0,29,33,31,47,12","w":184},"b":{"d":"184,-95v8,68,-63,129,-115,82v-1,6,-2,8,-5,13r-43,0v8,-68,5,-182,1,-255r49,-12v3,29,3,63,1,93v49,-40,118,4,112,79xm101,-37v28,0,25,-22,29,-57v6,-50,-34,-70,-56,-40r0,85v6,6,14,12,27,12","w":198},"c":{"d":"68,-89v0,60,36,70,67,39r22,29v-15,16,-33,25,-62,25v-51,0,-81,-35,-81,-95v0,-85,81,-126,138,-77r-24,31v-33,-28,-60,-14,-60,48","w":163},"d":{"d":"179,0r-43,0v-1,-3,-2,-6,-3,-11v-52,41,-119,-2,-119,-78v0,-71,55,-118,112,-87v-2,-24,0,-63,-1,-90r47,7v2,75,-6,204,7,259xm125,-48r0,-88v-31,-26,-57,-10,-57,47v0,54,32,65,57,41","w":197},"e":{"d":"95,-188v60,0,81,42,78,111r-106,1v-3,53,55,55,85,27r19,28v-58,53,-157,22,-157,-69v0,-58,29,-98,81,-98xm123,-112v0,-25,-6,-40,-27,-41v-18,0,-29,15,-29,41r56,0","w":182},"f":{"d":"127,-255r-15,30v-30,-19,-46,7,-40,41r47,0r-12,33r-35,0r0,151r-47,0r0,-151r-16,0r0,-33r17,0v-19,-67,46,-104,101,-71","w":109},"g":{"d":"94,-188v33,0,70,20,94,-7r20,31v-13,13,-29,16,-47,12v30,41,-6,91,-64,85v-12,6,-19,10,-19,15v4,8,24,3,34,5v46,-1,71,17,71,56v0,43,-43,62,-87,62v-45,0,-100,-23,-81,-72r45,0v-7,21,5,35,32,35v21,0,42,-6,42,-25v0,-49,-112,5,-112,-52v0,-12,3,-23,33,-31v-27,-7,-39,-24,-39,-51v0,-38,31,-63,78,-63xm122,-125v0,-17,-11,-27,-29,-27v-18,0,-29,10,-29,27v0,19,12,26,29,26v19,0,29,-9,29,-26","w":199},"h":{"d":"73,-170v36,-32,105,-27,105,41r0,129r-47,0r0,-124v1,-40,-40,-24,-57,-8r0,132r-49,0r0,-213v0,-17,-1,-34,-3,-42r49,-12v4,23,4,69,2,97","w":203},"i":{"d":"79,-235v0,17,-13,30,-30,30v-16,0,-29,-13,-29,-30v0,-17,13,-30,30,-30v16,0,29,13,29,30xm73,0r-48,0r0,-181r48,-8r0,189","w":98},"j":{"d":"80,-236v0,17,-14,30,-31,30v-17,0,-29,-13,-29,-29v0,-17,13,-30,30,-30v16,0,30,13,30,29xm2,53v16,-16,23,-25,23,-57r0,-173r48,-11v-10,95,32,243,-51,267","w":98},"k":{"d":"193,0r-57,0r-61,-104r47,-80r58,0r-59,77xm73,0r-48,0r0,-208v0,-16,0,-29,-3,-48r49,-11v5,80,1,182,2,267","w":186},"l":{"d":"75,-75v2,43,-6,43,18,45r8,29v-45,12,-75,-1,-76,-61r-2,-193r49,-11v6,50,2,133,3,191","w":101},"m":{"d":"158,-163v33,-39,102,-36,102,32r0,131r-47,0r0,-122v3,-44,-30,-24,-47,-10r0,132r-45,0r0,-120v2,-44,-30,-28,-49,-14r0,134r-47,0v-3,-54,7,-137,-7,-176r44,-12v3,5,4,10,6,19v25,-27,73,-24,90,6","w":285},"n":{"d":"68,-166v29,-30,103,-33,103,31r0,135r-48,0r0,-120v2,-44,-32,-26,-50,-10r0,130r-48,0v-2,-59,6,-128,-6,-177r43,-12v4,8,6,15,6,23","w":195},"o":{"d":"95,-188v51,0,85,38,84,95v-1,58,-28,97,-84,97v-50,0,-82,-37,-82,-95v0,-58,32,-97,82,-97xm66,-93v0,36,3,62,31,62v21,0,30,-18,30,-62v0,-37,-2,-59,-31,-59v-27,0,-30,27,-30,59","w":191},"p":{"d":"114,-188v48,0,66,33,70,91v5,74,-50,121,-113,91v2,22,0,49,1,73r-47,12r0,-213v0,-24,0,-31,-3,-46r43,-8v2,6,3,11,3,17v8,-10,27,-17,46,-17xm132,-93v-2,-32,-2,-56,-28,-56v-12,0,-23,5,-32,14r0,90v30,22,64,11,60,-48","w":198},"q":{"d":"14,-89v0,-60,28,-100,77,-100v19,0,39,9,43,19v0,-6,1,-10,4,-15r39,0v-9,74,-2,171,-4,253r-46,12v1,-29,-2,-64,2,-89v-54,39,-115,-16,-115,-80xm127,-49r0,-87v-7,-7,-16,-13,-27,-13v-29,0,-33,31,-33,54v0,24,1,60,33,60v11,0,21,-7,27,-14","w":198},"r":{"d":"130,-185r-13,43v-17,-9,-31,-1,-44,12r0,130r-48,0v-2,-55,6,-136,-7,-177r44,-12v4,8,6,17,7,27v13,-18,35,-35,61,-23","w":124},"s":{"d":"152,-90v41,87,-70,121,-143,75r17,-36v15,9,40,21,61,21v14,0,25,-9,25,-21v-2,-32,-69,-19,-84,-45v-25,-44,4,-93,61,-93v30,0,49,9,66,17r-16,32v-18,-9,-31,-13,-45,-13v-29,0,-34,33,-1,37v22,4,54,15,59,26","w":173},"t":{"d":"117,-4v-43,17,-92,9,-92,-47r0,-100r-18,0r0,-33r18,0v0,-18,0,-30,2,-44r49,-12v-2,17,-3,37,-3,56r43,0r-12,33r-31,0r0,92v-2,32,14,34,38,26","w":122},"u":{"d":"71,-71v-9,49,38,45,51,22r0,-130r46,-10v5,59,-12,134,11,175r-34,19v-6,-4,-12,-10,-15,-18v-38,34,-107,22,-107,-49r0,-118r48,-9r0,118","w":192},"v":{"d":"171,-184r-68,184r-40,0r-67,-181r50,-7r38,128v5,-39,25,-87,36,-124r51,0","w":167},"w":{"d":"252,-184r-53,184r-44,0r-30,-126v-7,42,-20,86,-30,126r-45,0r-50,-181r48,-5r25,128v1,-14,23,-100,31,-126r45,0r29,126v3,-29,17,-92,24,-126r50,0","w":251},"x":{"d":"92,-132v-1,-1,18,-43,25,-52r57,0r-55,85r66,99r-61,0r-34,-61v-2,9,-25,46,-33,61r-62,0r68,-98r-51,-78r50,-14v17,29,19,35,30,58","w":180},"y":{"d":"181,-184r-67,187v-21,56,-31,67,-80,78r-17,-32v29,-7,46,-21,54,-49r-12,0r-61,-181r50,-6r41,146v8,-47,28,-99,41,-143r51,0","w":178},"z":{"d":"158,-33r-11,33r-136,0r0,-30r87,-120r-80,0r0,-34r137,0r0,33r-82,118r85,0","w":168},"{":{"d":"130,56v-48,2,-83,1,-84,-52r0,-62v0,-22,-30,-25,-39,-25r0,-41v9,0,39,-3,39,-25v-2,-53,-4,-121,47,-115r37,0r0,42v-23,-3,-46,7,-41,23r0,58v1,35,-23,34,-36,38v15,1,36,4,36,37v0,39,-21,89,41,81r0,41","w":137},"|":{"d":"71,75r-46,0r0,-347r46,0r0,347","w":95},"}":{"d":"130,-83v-10,0,-39,3,-39,25v2,52,5,120,-46,114r-38,0r0,-41v23,3,47,-6,41,-23r0,-58v-1,-35,23,-34,36,-38v-15,-1,-36,-4,-36,-37v0,-39,22,-89,-41,-81r0,-42v49,-2,84,-2,84,53r0,62v0,22,29,25,39,25r0,41","w":137},"~":{"d":"61,-144v23,0,55,24,77,24v14,0,24,-13,32,-24r13,39v-8,15,-21,31,-45,31v-23,0,-56,-24,-77,-25v-14,0,-24,14,-32,25r-13,-39v8,-15,21,-31,45,-31","w":198},"\u00a1":{"d":"83,-158v0,17,-13,30,-30,30v-16,0,-30,-13,-30,-30v0,-17,14,-30,31,-30v16,0,29,13,29,30xm82,64r-57,8r10,-176r37,0","w":106},"\u00a2":{"d":"68,-89v0,60,36,70,67,39r22,29v-13,13,-26,20,-45,24r0,37r-34,0r0,-37v-40,-7,-64,-41,-64,-94v0,-55,23,-85,64,-96r0,-35r34,0r0,34v18,2,27,9,40,20r-24,31v-33,-28,-60,-14,-60,48","w":163},"\u00a3":{"d":"213,-235r-36,39v-25,-33,-81,-9,-74,29r0,18r56,0r0,37r-56,0r0,71r91,0r0,41r-180,0r0,-41r35,0r0,-71r-35,0r0,-37r35,0v-5,-65,21,-110,89,-110v27,0,55,6,75,24","w":209},"\u00a5":{"d":"206,-250r-56,101r38,0r0,37r-57,0v-5,6,-6,16,-5,27r62,0r0,37r-62,0r0,48r-53,0r0,-48r-61,0r0,-37r61,0v1,-11,0,-21,-5,-27r-56,0r0,-37r37,0r-54,-101r61,0r32,68v6,14,9,23,12,32r46,-100r60,0","w":200},"\u0192":{"d":"137,-255r-15,30v-29,-20,-44,10,-41,41r43,0r-12,34r-32,0r-10,138v-4,60,-14,65,-52,91r-22,-33v23,-18,28,-24,30,-50r10,-146r-16,0r0,-34r19,0v-2,-48,14,-84,59,-83v15,0,30,6,39,12","w":112},"\u00a7":{"d":"197,-101v0,20,-13,38,-30,47v13,10,20,25,20,42v0,82,-143,90,-173,21r46,-23v4,17,24,25,40,25v12,0,29,-4,29,-19v0,-34,-109,-28,-109,-97v0,-24,11,-42,31,-54v-14,-9,-22,-24,-22,-41v0,-77,127,-80,158,-22r-46,26v-6,-24,-56,-33,-56,-3v0,35,112,32,112,98xm135,-69v23,-13,11,-43,-11,-48r-42,-20v-25,16,-6,47,17,51","w":211},"\u00a4":{"d":"108,-78v9,42,62,58,97,27r12,39v-61,40,-157,1,-165,-66r-41,0r0,-35r36,0r1,-28r-37,0r0,-35r44,0v14,-64,97,-100,157,-67r-12,41v-33,-28,-83,-10,-91,26r70,0r0,35r-75,0r0,28r75,0r0,35r-71,0","w":224},"'":{"d":"69,-153r-46,0r0,-102r46,0r0,102","w":92},"\u201c":{"d":"138,-218v1,13,27,18,23,37v0,17,-13,31,-31,31v-60,0,-37,-101,14,-108r19,20v-15,4,-25,11,-25,20xm57,-218v1,13,28,18,23,37v0,17,-14,31,-32,31v-21,0,-35,-18,-35,-43v0,-31,20,-57,50,-65r19,20v-16,4,-25,11,-25,20","w":174},"\u00ab":{"d":"186,-27r-33,22r-57,-85r57,-84r33,22r-42,62xm99,-27r-33,22r-57,-85r57,-84r33,22r-42,62","w":195},"\u2013":{"d":"190,-80r-176,0r0,-37r176,0r0,37","w":204},"\u00b7":{"d":"78,-98v0,17,-14,31,-32,31v-18,0,-32,-14,-32,-32v0,-18,15,-32,33,-32v18,0,31,15,31,33","w":92},"\u00b6":{"d":"188,45r-32,0r0,-274r-39,0r0,274r-32,0r0,-167v-47,0,-78,-27,-78,-65v0,-83,100,-67,181,-68r0,300","w":213},"\u2022":{"d":"149,-127v0,35,-29,63,-64,63v-35,0,-63,-28,-63,-63v0,-35,28,-64,63,-64v35,0,64,29,64,64","w":170},"\u201d":{"d":"118,-188v-1,-13,-28,-18,-23,-37v0,-17,13,-31,31,-31v61,0,36,101,-15,108r-19,-20v15,-4,26,-11,26,-20xm37,-188v0,-13,-29,-18,-24,-37v0,-17,14,-31,32,-31v61,0,36,101,-15,108r-19,-20v15,-4,26,-11,26,-20","w":174},"\u00bb":{"d":"186,-90r-57,85r-33,-22r42,-63r-42,-62r33,-22xm99,-90r-57,85r-33,-22r42,-63r-42,-62r33,-22","w":195},"\u2026":{"d":"261,-26v0,18,-14,32,-31,32v-18,0,-32,-14,-32,-32v0,-17,14,-32,31,-32v18,0,32,15,32,32xm171,-26v0,18,-14,32,-31,32v-18,0,-32,-14,-32,-32v0,-17,14,-32,31,-32v18,0,32,15,32,32xm81,-26v0,18,-14,32,-31,32v-18,0,-32,-14,-32,-32v0,-17,14,-32,31,-32v18,0,32,15,32,32","w":279},"\u00bf":{"d":"125,-158v0,17,-13,30,-30,30v-16,0,-29,-13,-29,-30v0,-17,13,-30,30,-30v16,0,29,13,29,30xm158,43v-9,9,-33,28,-70,28v-37,0,-68,-23,-68,-61v0,-33,20,-45,33,-54v26,-18,30,-33,27,-60r41,0v9,34,1,58,-30,79v-10,7,-23,14,-23,29v-2,39,60,23,68,8","w":170},"`":{"d":"106,-227r-15,26r-80,-36r21,-37","w":117},"\u00b4":{"d":"106,-237r-80,36r-15,-26r74,-47","w":117},"\u00af":{"d":"120,-240r-113,0r0,-28r113,0r0,28","w":127},"\u00a8":{"d":"149,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm73,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27","w":167},"\u00b8":{"d":"89,40v0,31,-49,40,-71,23r11,-23v10,13,44,-1,19,-8v-8,2,-12,2,-15,-5r9,-31r26,2r-5,14v18,2,26,14,26,28","w":106},"\u2014":{"d":"271,-80r-257,0r0,-37r257,0r0,37","w":285},"\u00c6":{"d":"298,0r-147,0r0,-59r-69,0r-33,59r-56,0r149,-250r152,0r-7,41r-85,0r0,58r71,0r0,41r-71,0r0,67r96,0r0,43xm153,-189v0,0,-37,71,-47,88r45,0","w":305},"\u00aa":{"d":"18,-258v30,-24,117,-37,107,29v2,29,-8,65,13,77r-18,22v-9,-4,-18,-10,-21,-17v-21,30,-84,16,-84,-28v0,-34,29,-49,75,-47v3,-40,-34,-27,-57,-11xm142,-83r-131,0r0,-28r131,0r0,28xm89,-167v-2,-9,3,-25,-2,-30v-39,-8,-42,39,-17,39v6,0,14,-3,19,-9","w":153},"\u0141":{"d":"166,-42r-9,42r-132,0r0,-106r-20,7r0,-33r20,-7r0,-111r52,0r0,94r53,-17r0,33r-53,17r0,81r89,0","w":168},"\u00d8":{"d":"46,-28v-61,-72,-35,-225,77,-225v20,0,37,4,52,12r22,-35r26,14r-24,40v21,22,31,55,31,96v0,99,-73,156,-161,118r-24,40r-27,-15xm122,-215v-58,-1,-54,84,-47,139r77,-127v-7,-6,-17,-12,-30,-12xm172,-125v0,-19,-1,-35,-4,-47r-77,128v50,24,85,0,81,-81","w":244},"\u0152":{"d":"14,-126v0,-79,41,-124,132,-124r143,0r-6,41r-86,0r0,58r72,0r0,41r-72,0r0,67r97,0r0,43r-147,0v-99,6,-133,-40,-133,-126xm75,-130v0,59,20,105,75,87r0,-161v-45,-10,-75,7,-75,74","w":300},"\u00ba":{"d":"75,-275v39,0,64,28,63,71v-1,44,-21,73,-63,73v-37,0,-62,-29,-62,-72v0,-44,25,-72,62,-72xm142,-83r-131,0r0,-28r131,0r0,28xm54,-204v0,26,4,45,22,45v15,0,22,-14,22,-45v0,-26,-2,-42,-22,-42v-18,0,-22,18,-22,42","w":153},"\u00e6":{"d":"188,-188v59,3,80,42,77,111v-34,2,-76,-4,-106,2v-2,52,56,54,85,26r19,29v-36,32,-100,35,-131,1v-28,42,-119,32,-119,-32v0,-46,37,-65,99,-63v4,-54,-45,-35,-75,-14r-20,-34v28,-21,97,-40,127,-9v10,-9,26,-17,44,-17xm215,-112v1,-26,-6,-40,-27,-41v-18,0,-29,15,-29,41r56,0xm111,-41v-2,-12,4,-32,-2,-40v-33,0,-45,6,-45,28v0,29,33,31,47,12","w":274},"\u0131":{"d":"73,0r-48,0r0,-181r48,-8r0,189","w":98},"\u0142":{"d":"75,-120v5,36,-15,101,18,90r8,29v-45,12,-84,-1,-76,-61r0,-41r-14,5r0,-33r14,-5r-2,-119r49,-11v5,22,2,81,3,113r19,-6r0,33","w":101},"\u00f8":{"d":"155,-163v48,51,24,167,-60,167v-14,0,-26,-3,-37,-8r-21,34r-22,-12r22,-37v-48,-50,-21,-169,58,-169v15,0,28,3,40,9r21,-35r22,13xm114,-145v-31,-21,-48,11,-48,52v0,9,1,18,1,25xm97,-31v27,7,33,-46,29,-84r-48,78v5,4,13,6,19,6","w":191},"\u0153":{"d":"202,-188v59,0,81,43,78,111v-34,2,-77,-4,-107,2v-2,52,57,54,86,26r19,29v-35,30,-93,34,-128,5v-53,44,-137,8,-137,-76v0,-83,80,-124,136,-78v14,-13,31,-19,53,-19xm230,-112v0,-27,-6,-41,-27,-41v-18,0,-29,15,-29,41r56,0xm66,-93v0,36,3,62,31,62v21,0,30,-18,30,-62v0,-37,-2,-59,-31,-59v-27,0,-30,27,-30,59","w":288},"\u00df":{"d":"32,-184v-5,-49,28,-74,76,-77v82,-5,102,84,40,111v-9,4,-6,11,4,16v37,15,51,27,54,65v4,52,-54,87,-109,69r11,-33v46,16,60,-50,24,-68v-30,-7,-45,-55,-12,-71v21,-11,14,-54,-13,-52v-22,2,-26,17,-26,47v0,56,7,134,-7,177r-49,0v11,-33,6,-101,7,-147r-29,0r0,-37r29,0","w":216},"\u0178":{"d":"161,-286v0,15,-13,28,-28,28v-15,0,-28,-13,-28,-28v0,-15,14,-28,29,-28v15,0,27,13,27,28xm85,-286v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm201,-250r-80,147r0,103r-52,0r0,-103r-78,-147r60,0v15,31,35,67,45,100v14,-35,30,-67,46,-100r59,0","w":192},"\u2122":{"d":"346,-107r-39,0r-1,-96r-35,96r-25,0r-36,-96r0,96r-39,0r0,-148r52,0r35,97r35,-97r53,0r0,148xm139,-220r-43,0r0,113r-39,0r0,-113r-43,0r0,-35r125,0r0,35","w":367},"\u017e":{"d":"151,-248r-65,49r-66,-49r16,-26r50,27r49,-27xm158,-33r-11,33r-136,0r0,-30r87,-120r-80,0r0,-34r137,0r0,33r-82,118r85,0","w":168},"\u017d":{"d":"160,-313r-65,49r-66,-49r16,-26r50,27r49,-27xm180,-41r-13,41r-156,0r0,-35r107,-175v-22,3,-73,2,-102,2r11,-42r150,0r0,36r-93,157v-5,9,-13,17,-13,17v29,-2,76,-1,109,-1","w":190},"\u0161":{"d":"150,-248r-65,49r-66,-49r16,-26r50,27r49,-27xm152,-90v41,87,-70,121,-143,75r17,-36v15,9,40,21,61,21v14,0,25,-9,25,-21v-2,-32,-69,-19,-84,-45v-25,-44,4,-93,61,-93v30,0,49,9,66,17r-16,32v-18,-9,-31,-13,-45,-13v-29,0,-34,33,-1,37v22,4,54,15,59,26","w":173},"\u0160":{"d":"173,-313r-65,49r-66,-49r16,-26r50,27r49,-27xm199,-79v0,84,-122,105,-188,62r19,-40v33,23,112,37,112,-14v0,-45,-93,-35,-110,-71v-27,-58,12,-116,80,-116v31,0,61,9,83,25r-24,36v-23,-14,-39,-19,-58,-19v-21,0,-35,12,-35,29v0,22,38,28,58,34v41,12,63,37,63,74","w":210},"\u00ff":{"d":"159,-229v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm84,-229v0,15,-13,28,-28,28v-15,0,-28,-13,-28,-28v0,-15,14,-27,29,-27v15,0,27,12,27,27xm181,-184r-67,187v-21,56,-31,67,-80,78r-17,-32v29,-7,46,-21,54,-49r-12,0r-61,-181r50,-6r41,146v8,-47,28,-99,41,-143r51,0","w":178},"\u00fe":{"d":"183,-95v8,67,-60,126,-113,85r0,77r-46,12r0,-289v0,-23,0,-35,-3,-45r49,-12v3,29,3,63,1,93v49,-40,118,4,112,79xm72,-49v26,25,66,7,56,-45v10,-51,-33,-69,-56,-40r0,85","w":197},"\u00fd":{"d":"150,-237r-81,36r-15,-26r75,-47xm181,-184r-67,187v-21,56,-31,67,-80,78r-17,-32v29,-7,46,-21,54,-49r-12,0r-61,-181r50,-6r41,146v8,-47,28,-99,41,-143r51,0","w":178},"\u00fc":{"d":"162,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm84,-229v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm71,-71v-9,49,38,45,51,22r0,-130r46,-10v5,59,-12,134,11,175r-34,19v-6,-4,-12,-10,-15,-18v-38,34,-107,22,-107,-49r0,-118r48,-9r0,118","w":192},"\u00fb":{"d":"162,-225r-16,26r-50,-27r-48,27r-17,-26r65,-49xm71,-71v-9,49,38,45,51,22r0,-130r46,-10v5,59,-12,134,11,175r-34,19v-6,-4,-12,-10,-15,-18v-38,34,-107,22,-107,-49r0,-118r48,-9r0,118","w":192},"\u00fa":{"d":"153,-237r-81,36r-14,-26r74,-47xm71,-71v-9,49,38,45,51,22r0,-130r46,-10v5,59,-12,134,11,175r-34,19v-6,-4,-12,-10,-15,-18v-38,34,-107,22,-107,-49r0,-118r48,-9r0,118","w":192},"\u00f9":{"d":"140,-227r-14,26r-81,-36r21,-37xm71,-71v-9,49,38,45,51,22r0,-130r46,-10v5,59,-12,134,11,175r-34,19v-6,-4,-12,-10,-15,-18v-38,34,-107,22,-107,-49r0,-118r48,-9r0,118","w":192},"\u00f7":{"d":"136,-168v0,17,-14,31,-31,31v-17,0,-31,-14,-31,-31v0,-17,14,-31,31,-31v17,0,31,14,31,31xm196,-77r-182,0r0,-38r182,0r0,38xm136,-24v0,17,-15,30,-32,30v-17,0,-31,-13,-31,-30v0,-18,15,-33,32,-33v17,0,31,15,31,33","w":210},"\u00f6":{"d":"161,-229v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm85,-229v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm95,-188v51,0,85,38,84,95v-1,58,-28,97,-84,97v-50,0,-82,-37,-82,-95v0,-58,32,-97,82,-97xm66,-93v0,36,3,62,31,62v21,0,30,-18,30,-62v0,-37,-2,-59,-31,-59v-27,0,-30,27,-30,59","w":191},"\u00f5":{"d":"161,-230v-11,14,-24,21,-45,21v-27,0,-50,-23,-71,-2r-15,-27v10,-13,25,-21,45,-21v26,0,51,24,71,2xm95,-188v51,0,85,38,84,95v-1,58,-28,97,-84,97v-50,0,-82,-37,-82,-95v0,-58,32,-97,82,-97xm66,-93v0,36,3,62,31,62v21,0,30,-18,30,-62v0,-37,-2,-59,-31,-59v-27,0,-30,27,-30,59","w":191},"\u00f4":{"d":"162,-225r-17,26r-50,-27r-48,27r-16,-26r64,-49xm95,-188v51,0,85,38,84,95v-1,58,-28,97,-84,97v-50,0,-82,-37,-82,-95v0,-58,32,-97,82,-97xm66,-93v0,36,3,62,31,62v21,0,30,-18,30,-62v0,-37,-2,-59,-31,-59v-27,0,-30,27,-30,59","w":191},"\u00f3":{"d":"148,-237r-80,36r-15,-26r74,-47xm95,-188v51,0,85,38,84,95v-1,58,-28,97,-84,97v-50,0,-82,-37,-82,-95v0,-58,32,-97,82,-97xm66,-93v0,36,3,62,31,62v21,0,30,-18,30,-62v0,-37,-2,-59,-31,-59v-27,0,-30,27,-30,59","w":191},"\u00f2":{"d":"129,-227r-15,26r-81,-36r21,-37xm95,-188v51,0,85,38,84,95v-1,58,-28,97,-84,97v-50,0,-82,-37,-82,-95v0,-58,32,-97,82,-97xm66,-93v0,36,3,62,31,62v21,0,30,-18,30,-62v0,-37,-2,-59,-31,-59v-27,0,-30,27,-30,59","w":191},"\u00f1":{"d":"163,-230v-11,14,-24,21,-45,21v-27,0,-51,-23,-72,-2r-14,-27v10,-13,24,-21,44,-21v26,0,51,24,72,2xm68,-166v29,-30,103,-33,103,31r0,135r-48,0r0,-120v2,-44,-32,-26,-50,-10r0,130r-48,0v-2,-59,6,-128,-6,-177r43,-12v4,8,6,15,6,23","w":195},"\u00f0":{"d":"105,-218v39,24,70,79,70,131v0,60,-35,91,-81,91v-45,0,-80,-30,-80,-81v1,-52,40,-81,95,-74v-8,-12,-20,-25,-33,-34r-14,17r-30,-13r18,-19v-14,-6,-31,-12,-51,-14r28,-34v15,2,33,7,51,15r12,-13r29,13xm96,-35v28,0,35,-41,29,-72v-22,-13,-62,-10,-62,31v0,24,12,41,33,41","w":189},"\u00ef":{"d":"115,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm39,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm73,0r-48,0r0,-181r48,-8r0,189","w":98},"\u00ee":{"d":"115,-225r-16,26r-50,-27r-49,27r-16,-26r65,-49xm73,0r-48,0r0,-181r48,-8r0,189","w":98},"\u00ed":{"d":"107,-237r-80,36r-15,-26r74,-47xm73,0r-48,0r0,-181r48,-8r0,189","w":98},"\u00ec":{"d":"88,-227r-15,26r-80,-36r21,-37xm73,0r-48,0r0,-181r48,-8r0,189","w":98},"\u00eb":{"d":"161,-229v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm85,-229v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm95,-188v60,0,81,42,78,111r-106,1v-3,53,55,55,85,27r19,28v-58,53,-157,22,-157,-69v0,-58,29,-98,81,-98xm123,-112v0,-25,-6,-40,-27,-41v-18,0,-29,15,-29,41r56,0","w":182},"\u00ea":{"d":"161,-225r-16,26r-50,-27r-49,27r-16,-26r65,-49xm95,-188v60,0,81,42,78,111r-106,1v-3,53,55,55,85,27r19,28v-58,53,-157,22,-157,-69v0,-58,29,-98,81,-98xm123,-112v0,-25,-6,-40,-27,-41v-18,0,-29,15,-29,41r56,0","w":182},"\u00e9":{"d":"148,-237r-81,36r-14,-26r74,-47xm95,-188v60,0,81,42,78,111r-106,1v-3,53,55,55,85,27r19,28v-58,53,-157,22,-157,-69v0,-58,29,-98,81,-98xm123,-112v0,-25,-6,-40,-27,-41v-18,0,-29,15,-29,41r56,0","w":182},"\u00e8":{"d":"130,-227r-15,26r-81,-36r21,-37xm95,-188v60,0,81,42,78,111r-106,1v-3,53,55,55,85,27r19,28v-58,53,-157,22,-157,-69v0,-58,29,-98,81,-98xm123,-112v0,-25,-6,-40,-27,-41v-18,0,-29,15,-29,41r56,0","w":182},"\u00e7":{"d":"68,-89v0,60,36,70,67,39r22,29v-15,16,-33,24,-59,25r-3,8v18,2,26,14,26,28v0,31,-48,40,-71,23r11,-23v10,13,44,-1,19,-8v-22,5,-10,-18,-8,-30v-37,-9,-58,-43,-58,-93v0,-85,81,-126,138,-77r-24,31v-33,-28,-60,-14,-60,48","w":163},"\u00e5":{"d":"130,-237v0,21,-17,38,-38,38v-21,0,-38,-17,-38,-38v0,-21,18,-38,39,-38v21,0,37,17,37,38xm17,-162v41,-31,155,-49,142,39v3,40,-13,84,17,103r-26,29v-11,-5,-21,-13,-26,-22v-29,37,-111,21,-111,-38v0,-46,37,-65,99,-63v4,-54,-45,-35,-75,-14xm110,-237v0,-10,-7,-19,-17,-19v-10,0,-19,9,-19,19v0,10,8,18,18,18v10,0,18,-8,18,-18xm111,-41v-2,-12,4,-32,-2,-40v-33,0,-45,6,-45,28v0,29,33,31,47,12","w":184},"\u00e4":{"d":"156,-229v0,16,-13,29,-29,29v-16,0,-28,-13,-28,-29v0,-16,13,-28,29,-28v15,0,28,12,28,28xm80,-229v0,16,-13,29,-29,29v-15,0,-28,-13,-28,-29v0,-16,13,-28,29,-28v15,0,28,12,28,28xm17,-162v42,-32,155,-48,142,39v3,40,-13,84,17,103r-26,29v-11,-5,-21,-13,-26,-22v-30,37,-111,21,-111,-38v0,-46,37,-65,99,-63v4,-54,-45,-35,-75,-14xm111,-41v-2,-12,4,-32,-2,-40v-33,0,-45,6,-45,28v0,29,33,31,47,12","w":184},"\u00e3":{"d":"157,-230v-11,14,-24,21,-45,21v-27,0,-50,-23,-71,-2r-15,-27v10,-13,25,-21,45,-21v26,0,51,24,71,2xm17,-162v41,-31,155,-49,142,39v3,40,-13,84,17,103r-26,29v-11,-5,-21,-13,-26,-22v-29,37,-111,21,-111,-38v0,-46,37,-65,99,-63v4,-54,-45,-35,-75,-14xm111,-41v-2,-12,4,-32,-2,-40v-33,0,-45,6,-45,28v0,29,33,31,47,12","w":184},"\u00e2":{"d":"156,-225r-17,26r-50,-27r-48,27r-17,-26r65,-49xm17,-162v41,-31,155,-49,142,39v3,40,-13,84,17,103r-26,29v-11,-5,-21,-13,-26,-22v-29,37,-111,21,-111,-38v0,-46,37,-65,99,-63v4,-54,-45,-35,-75,-14xm111,-41v-2,-12,4,-32,-2,-40v-33,0,-45,6,-45,28v0,29,33,31,47,12","w":184},"\u00e1":{"d":"147,-237r-81,36r-15,-26r75,-47xm17,-162v41,-31,155,-49,142,39v3,40,-13,84,17,103r-26,29v-11,-5,-21,-13,-26,-22v-29,37,-111,21,-111,-38v0,-46,37,-65,99,-63v4,-54,-45,-35,-75,-14xm111,-41v-2,-12,4,-32,-2,-40v-33,0,-45,6,-45,28v0,29,33,31,47,12","w":184},"\u00e0":{"d":"135,-227r-14,26r-81,-36r21,-37xm17,-162v40,-30,155,-50,142,39v3,40,-13,84,17,103r-26,29v-11,-5,-21,-13,-26,-22v-29,37,-121,21,-111,-38v-2,-46,37,-65,99,-63v4,-54,-45,-35,-75,-14xm111,-41v-2,-12,4,-32,-2,-40v-33,0,-45,6,-45,28v0,29,33,31,47,12","w":184},"\u00de":{"d":"76,-211v80,-3,121,16,121,77v0,60,-44,88,-121,81r0,53r-51,0r0,-250r51,0r0,39xm76,-94v39,2,65,0,65,-38v0,-37,-28,-41,-65,-38r0,76","w":203},"\u00dd":{"d":"153,-294r-81,36r-14,-27r74,-47xm201,-250r-80,147r0,103r-52,0r0,-103r-78,-147r60,0v15,31,35,67,45,100v14,-35,30,-67,46,-100r59,0","w":192},"\u00dc":{"d":"180,-286v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm104,-286v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm114,-39v31,0,39,-15,39,-51r0,-160r51,0r0,168v0,24,1,29,-3,40v-6,20,-31,47,-85,47v-57,0,-93,-21,-92,-81r0,-174r52,0r0,164v-1,35,9,47,38,47","w":228},"\u00db":{"d":"182,-283r-16,27r-50,-28r-49,28r-16,-27r65,-48xm114,-39v31,0,39,-15,39,-51r0,-160r51,0r0,168v0,24,1,29,-3,40v-6,20,-31,47,-85,47v-57,0,-93,-21,-92,-81r0,-174r52,0r0,164v-1,35,9,47,38,47","w":228},"\u00da":{"d":"174,-294r-81,36r-15,-27r75,-47xm114,-39v31,0,39,-15,39,-51r0,-160r51,0r0,168v0,24,1,29,-3,40v-6,20,-31,47,-85,47v-57,0,-93,-21,-92,-81r0,-174r52,0r0,164v-1,35,9,47,38,47","w":228},"\u00d9":{"d":"156,-285r-15,27r-81,-36r21,-38xm114,-39v31,0,39,-15,39,-51r0,-160r51,0r0,168v0,24,1,29,-3,40v-6,20,-31,47,-85,47v-57,0,-93,-21,-92,-81r0,-174r52,0r0,164v-1,35,9,47,38,47","w":228},"\u00d7":{"d":"197,-55r-32,32r-54,-54r-54,54r-32,-32r54,-54r-54,-54r32,-32r54,54r54,-54r32,32r-54,54","w":221},"\u00d6":{"d":"188,-286v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm112,-286v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm14,-124v0,-74,35,-129,109,-129v67,0,107,49,107,127v0,77,-31,127,-105,130v-75,3,-111,-57,-111,-128xm71,-124v1,59,6,89,52,89v35,0,49,-26,49,-90v0,-54,0,-82,-50,-90v-43,3,-52,41,-51,91","w":244},"\u00d5":{"d":"186,-288v-11,14,-24,21,-45,21v-27,0,-51,-23,-72,-2r-14,-27v25,-44,87,10,116,-19xm12,-124v0,-74,35,-129,109,-129v67,0,107,49,107,127v0,76,-32,127,-106,130v-75,3,-110,-57,-110,-128xm68,-124v0,59,7,89,53,89v35,0,49,-26,49,-90v0,-54,0,-82,-50,-90v-43,3,-52,41,-52,91","w":240},"\u00d4":{"d":"189,-283r-16,27r-50,-28r-49,28r-16,-27r65,-48xm14,-124v0,-74,35,-129,109,-129v67,0,107,49,107,127v0,77,-31,127,-105,130v-75,3,-111,-57,-111,-128xm71,-124v1,59,6,89,52,89v35,0,49,-26,49,-90v0,-54,0,-82,-50,-90v-43,3,-52,41,-51,91","w":244},"\u00d3":{"d":"173,-294r-80,36r-15,-27r74,-47xm14,-124v0,-74,35,-129,109,-129v67,0,107,49,107,127v0,77,-31,127,-105,130v-75,3,-111,-57,-111,-128xm71,-124v1,59,6,89,52,89v35,0,49,-26,49,-90v0,-54,0,-82,-50,-90v-43,3,-52,41,-51,91","w":244},"\u00d2":{"d":"165,-285r-15,27r-81,-36r21,-38xm14,-124v0,-74,35,-129,109,-129v67,0,107,49,107,127v0,77,-31,127,-105,130v-75,3,-111,-57,-111,-128xm71,-124v1,59,6,89,52,89v35,0,49,-26,49,-90v0,-54,0,-82,-50,-90v-43,3,-52,41,-51,91","w":244},"\u00d1":{"d":"175,-288v-25,45,-85,-8,-116,19r-15,-27v25,-44,87,11,117,-19xm199,0r-52,0r-77,-178r4,178r-49,0r0,-250r56,0v24,52,60,117,75,171v-6,-55,-4,-113,-5,-171r48,0r0,250","w":224},"\u00d0":{"d":"76,-250v92,-8,132,41,132,126v0,75,-38,133,-122,124r-61,0r0,-110r-27,0r0,-32r27,0r0,-108r51,0xm152,-120v1,-58,-12,-99,-76,-91r0,69r39,0r-9,32r-30,0r0,69v56,5,75,-13,76,-79","w":222},"\u00cf":{"d":"117,-286v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm41,-286v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm78,0r-53,0r0,-250r53,0r0,250","w":102},"\u00ce":{"d":"117,-283r-16,27r-50,-28r-49,28r-16,-27r65,-48xm78,0r-53,0r0,-250r53,0r0,250","w":102},"\u00cd":{"d":"106,-294r-80,36r-15,-27r74,-47xm78,0r-53,0r0,-250r53,0r0,250","w":102},"\u00cc":{"d":"94,-285r-15,27r-81,-36r21,-38xm78,0r-53,0r0,-250r53,0r0,250","w":102},"\u00cb":{"d":"162,-286v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm86,-286v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm171,0r-146,0r0,-250r143,0r-7,41r-85,0r0,58r71,0r0,41r-71,0r0,67r95,0r0,43","w":178},"\u00ca":{"d":"161,-283r-16,27r-50,-28r-49,28r-16,-27r65,-48xm171,0r-146,0r0,-250r143,0r-7,41r-85,0r0,58r71,0r0,41r-71,0r0,67r95,0r0,43","w":178},"\u00c9":{"d":"144,-294r-81,36r-14,-27r74,-47xm171,0r-146,0r0,-250r143,0r-7,41r-85,0r0,58r71,0r0,41r-71,0r0,67r95,0r0,43","w":178},"\u00c8":{"d":"135,-285r-14,27r-81,-36r21,-38xm171,0r-146,0r0,-250r143,0r-7,41r-85,0r0,58r71,0r0,41r-71,0r0,67r95,0r0,43","w":178},"\u00c7":{"d":"71,-130v-8,81,45,118,102,79r23,32v-22,17,-44,24,-76,23r-2,8v18,2,26,14,26,28v0,31,-49,40,-71,23r11,-23v10,13,44,-1,19,-8v-24,5,-10,-18,-8,-31v-49,-12,-81,-61,-81,-121v0,-105,96,-171,176,-116r-22,34v-51,-35,-105,3,-97,72","w":203},"\u00c5":{"d":"144,-295v0,21,-17,38,-38,38v-21,0,-38,-17,-38,-38v0,-21,18,-38,39,-38v21,0,37,17,37,38xm212,0r-54,0r-17,-59r-74,0r-17,59r-53,0r82,-251r55,0xm124,-295v0,-10,-7,-18,-17,-18v-10,0,-19,8,-19,18v0,10,8,19,18,19v10,0,18,-9,18,-19xm129,-101v-2,-2,-22,-83,-24,-95r-25,95r49,0","w":209},"\u00c4":{"d":"172,-286v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm96,-286v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm212,0r-54,0r-17,-59r-74,0r-17,59r-53,0r82,-251r55,0xm129,-101v-2,-2,-22,-83,-24,-95r-25,95r49,0","w":209},"\u00c3":{"d":"169,-288v-11,14,-24,21,-45,21v-27,0,-50,-23,-71,-2r-15,-27v25,-44,87,10,116,-19xm212,0r-54,0r-17,-59r-74,0r-17,59r-53,0r82,-251r55,0xm129,-101v-2,-2,-22,-83,-24,-95r-25,95r49,0","w":209},"\u00c2":{"d":"170,-283r-16,27r-50,-28r-49,28r-16,-27r65,-48xm212,0r-54,0r-17,-59r-74,0r-17,59r-53,0r82,-251r55,0xm129,-101v-2,-2,-22,-83,-24,-95r-25,95r49,0","w":209},"\u00c1":{"d":"161,-294r-81,36r-14,-27r74,-47xm212,0r-54,0r-17,-59r-74,0r-17,59r-53,0r82,-251r55,0xm129,-101v-2,-2,-22,-83,-24,-95r-25,95r49,0","w":209},"\u00c0":{"d":"148,-285r-14,27r-81,-36r21,-38xm212,0r-54,0r-17,-59r-74,0r-17,59r-53,0r82,-251r55,0xm129,-101v-2,-2,-22,-83,-24,-95r-25,95r49,0","w":209},"\u00b1":{"d":"167,-102r-54,0r0,52r-45,0r0,-52r-54,0r0,-41r54,0r0,-49r45,0r0,49r54,0r0,41xm166,0r-151,0r0,-41r151,0r0,41","w":181},"\u00b0":{"d":"72,-254v36,0,63,24,62,62v0,39,-22,63,-62,63v-37,0,-61,-24,-61,-62v0,-37,24,-63,61,-63xm50,-192v0,24,3,36,22,36v15,0,22,-11,22,-37v0,-22,-6,-34,-23,-34v-17,0,-21,14,-21,35","w":144},"\u00ae":{"d":"282,-127v0,74,-60,133,-134,133v-74,0,-134,-59,-134,-133v0,-74,60,-134,134,-134v74,0,134,60,134,134xm246,-127v0,-56,-44,-102,-98,-102v-54,0,-97,46,-97,102v0,56,43,101,97,101v54,0,98,-45,98,-101xm209,-62r-42,0r-33,-54r0,54r-35,0r0,-137v47,-1,99,-5,99,42v0,21,-14,35,-32,37v17,6,39,54,43,58xm161,-157v1,-13,-12,-15,-27,-14r0,28v15,1,29,-2,27,-14","w":296},"\u00ac":{"d":"173,-21r-44,0r0,-50r-115,0r0,-40r159,0r0,90","w":187},"\u00a9":{"d":"282,-127v0,74,-60,133,-134,133v-74,0,-134,-59,-134,-133v0,-74,60,-134,134,-134v74,0,134,60,134,134xm246,-127v0,-56,-44,-102,-98,-102v-54,0,-97,46,-97,102v0,56,43,101,97,101v54,0,98,-45,98,-101xm194,-71v-44,35,-109,7,-109,-54v0,-60,62,-95,106,-60r-16,23v-27,-19,-51,-8,-51,32v0,47,29,56,53,36","w":296},"\u00a6":{"d":"71,-123r-46,0r0,-149r46,0r0,149xm71,75r-46,0r0,-149r46,0r0,149","w":95},"\u00b3":{"d":"121,-139v1,37,-51,59,-100,50r-10,-26v34,7,70,-4,69,-26v-2,-20,-23,-14,-41,-15r0,-29v16,3,41,1,39,-13v-3,-21,-38,-10,-47,1r-20,-23v29,-28,104,-28,106,19v0,13,-6,24,-17,31v13,6,21,17,21,31","w":131},"\u00b2":{"d":"124,-120r-8,30r-99,0r0,-24v17,-17,63,-55,59,-76v-4,-27,-25,-15,-45,0r-20,-23v31,-33,104,-33,105,20v0,28,-33,55,-53,73r61,0","w":134},"\u00b9":{"d":"102,-90r-77,0r0,-29r23,0r0,-75v-8,4,-16,8,-27,12r-10,-20v24,-11,34,-36,73,-32r0,115r18,0r0,29","w":113},"\u00be":{"d":"338,-26r-16,0r0,31r-34,4r0,-35r-64,0v1,-52,27,-77,39,-118r38,0r-37,88r25,0v0,-18,2,-33,4,-51r29,-6r0,57r16,0r0,30xm294,-275r-190,330r-39,0r190,-330r39,0xm121,-139v1,37,-51,59,-100,50r-10,-26v34,7,70,-4,69,-26v-2,-20,-23,-14,-41,-15r0,-29v16,3,41,1,39,-13v-3,-21,-38,-10,-47,1r-20,-23v29,-28,104,-28,106,19v0,13,-6,24,-17,31v13,6,21,17,21,31","w":348},"\u00bd":{"d":"318,-30r-8,30r-99,0r0,-24v17,-17,63,-55,59,-76v-4,-27,-25,-15,-45,0r-20,-23v31,-33,105,-34,105,20v0,28,-32,55,-52,73r60,0xm268,-275r-190,330r-39,0r190,-330r39,0xm102,-90r-77,0r0,-29r23,0r0,-75v-8,4,-16,8,-27,12r-10,-20v24,-11,34,-36,73,-32r0,115r18,0r0,29","w":329},"\u00bc":{"d":"319,-26r-16,0r0,31r-34,4r0,-35r-64,0v1,-52,27,-77,39,-118r38,0r-37,88r25,0v0,-18,2,-33,4,-51r29,-6r0,57r16,0r0,30xm275,-275r-190,330r-39,0r191,-330r38,0xm102,-90r-77,0r0,-29r23,0r0,-75v-8,4,-16,8,-27,12r-10,-20v24,-11,34,-36,73,-32r0,115r18,0r0,29","w":329},"\u00a0":{"w":81}}});
/*!
 * The following copyright notice may not be removed under any circumstances.
 *
 * Copyright:
 * < info@fontfont.de > Copyright Erik Spiekermann, 1991, 93, 98. Published by
 * FontShop International for  FontFont Release 23, Meta is a trademark of FSI
 * Fonts and Software GmbH.
 */
Cufon.registerFont({"w":201,"face":{"font-family":"Meta","font-weight":400,"font-style":"italic","font-stretch":"normal","units-per-em":"360","panose-1":"2 0 5 3 0 0 0 0 0 0","ascent":"288","descent":"-72","x-height":"5","bbox":"-36 -333 335 75","underline-thickness":"7.2","underline-position":"-51.12","unicode-range":"U+0020-U+2122"},"glyphs":{" ":{"w":81},"!":{"d":"100,-252r-45,181r-22,0r31,-176xm59,-20v0,13,-10,23,-22,23v-12,0,-22,-11,-22,-23v0,-12,10,-22,22,-22v12,0,22,10,22,22","w":102},"\"":{"d":"148,-255r-19,87r-26,0r19,-87r26,0xm95,-255r-19,87r-26,0r19,-87r26,0","w":143},"#":{"d":"210,-155r-41,0r-19,55r32,0r0,23r-41,0r-27,77r-24,0r27,-77r-46,0r-27,77r-24,0r27,-77r-33,0r0,-23r42,0r19,-55r-33,0r0,-24r42,0r27,-76r24,0r-27,76r45,0r27,-76r24,0r-27,76r33,0r0,24xm145,-155r-46,0r-19,55r46,0","w":205},"$":{"d":"197,-231r-15,22v-16,-12,-29,-18,-46,-19r-19,88v32,11,53,32,53,67v0,39,-31,71,-84,77r-7,35r-21,0r7,-34v-26,0,-46,-7,-65,-20r14,-23v17,12,33,18,56,19r21,-100v-32,-10,-51,-29,-51,-62v0,-39,34,-67,80,-71r6,-30r21,0r-6,30v22,2,41,9,56,21xm114,-227v-47,4,-61,61,-16,78xm91,-21v50,-8,69,-68,20,-89","w":191},"%":{"d":"261,-247r-173,247r-24,0r173,-247r24,0xm288,-76v0,49,-31,80,-73,80v-28,0,-47,-14,-47,-45v0,-44,30,-79,72,-79v32,0,48,20,48,44xm154,-206v0,49,-31,80,-73,80v-28,0,-46,-14,-46,-45v0,-44,30,-78,72,-78v32,0,47,19,47,43xm263,-73v0,-18,-9,-27,-27,-27v-30,0,-43,25,-43,58v0,19,10,26,27,26v28,0,43,-25,43,-57xm130,-203v0,-18,-9,-27,-27,-27v-30,0,-43,25,-43,58v0,19,10,26,27,26v28,0,43,-25,43,-57","w":306},"&":{"d":"220,0r-37,0r-20,-23v-34,41,-147,40,-147,-26v0,-27,11,-53,64,-75v-48,-48,-15,-112,54,-112v72,0,71,81,14,103r-24,12r45,57v10,-12,19,-56,19,-56r25,0v-7,34,-15,55,-30,75xm110,-137v27,-14,49,-22,49,-53v0,-16,-12,-25,-29,-25v-17,0,-41,13,-41,34v0,18,3,23,21,44xm152,-40r-57,-69v-33,14,-48,29,-48,55v0,47,86,43,105,14","w":243},"\u2019":{"d":"75,-251v37,0,29,52,5,73v-10,8,-25,19,-35,23r-9,-16v15,-7,27,-19,31,-32v-11,0,-19,-10,-19,-22v0,-16,12,-26,27,-26","w":93},"(":{"d":"163,-261v-78,31,-104,116,-104,217v0,39,10,67,38,85r-11,15v-97,-43,-43,-251,13,-295v19,-15,39,-31,58,-38","w":115},")":{"d":"-36,37v79,-30,104,-116,104,-217v0,-39,-10,-66,-38,-84r11,-14v98,43,43,251,-13,295v-19,15,-39,31,-58,38","w":115},"*":{"d":"176,-198r-51,18r32,42r-18,14r-32,-44r-31,44r-18,-14r31,-42r-51,-18r7,-21r51,18r0,-54r22,0r0,54r51,-18","w":164},"+":{"d":"176,-103r-5,26r-63,0r-14,64r-27,0r13,-64r-63,0r5,-26r64,0r13,-64r28,0r-14,64r63,0","w":190},",":{"d":"35,-45v36,0,27,52,4,73v-12,11,-24,19,-34,23r-9,-15v15,-7,27,-19,31,-32v-11,0,-19,-11,-19,-23v0,-16,12,-26,27,-26","w":100},"-":{"d":"99,-110r-5,28r-69,0r6,-28r68,0","w":119},".":{"d":"60,-20v0,14,-11,25,-24,25v-14,0,-24,-11,-24,-25v0,-13,11,-24,24,-24v14,0,24,11,24,24","w":99},"\/":{"d":"171,-273r-162,326r-24,0r163,-326r23,0","w":145},"0":{"d":"23,-79v1,-80,43,-161,112,-161v33,0,61,24,61,82v0,88,-41,164,-114,164v-34,0,-59,-28,-59,-85xm86,-16v52,0,80,-80,80,-148v0,-33,-11,-53,-32,-53v-50,1,-81,93,-81,148v0,35,15,53,33,53"},"1":{"d":"165,-235r-46,212r37,0r-5,23r-102,0r4,-23r38,0r38,-178v-14,9,-31,19,-63,32r-3,-17r79,-49r23,0"},"2":{"d":"195,-183v0,69,-102,132,-136,161r103,-1r-8,23r-139,0r4,-16v36,-21,157,-128,144,-161v0,-27,-14,-38,-36,-38v-16,0,-32,7,-59,26r-10,-17v31,-23,54,-33,80,-33v33,0,57,20,57,56"},"3":{"d":"78,-139v58,3,74,-7,81,-48v-7,-45,-68,-29,-97,-5r-10,-17v31,-21,54,-30,81,-30v36,0,57,20,57,47v0,31,-23,56,-56,65v25,4,40,26,40,47v0,66,-80,99,-159,91r-3,-21v61,9,131,-18,131,-70v0,-34,-24,-42,-70,-38"},"4":{"d":"186,-67r-4,22v-16,3,-35,-10,-33,14r-6,32r-30,9r12,-55r-107,0r5,-22r121,-169r31,0r-123,170v22,-2,54,-1,78,-1v5,-33,18,-63,25,-94r24,-6r-22,100r29,0"},"5":{"d":"196,-233r-9,24r-78,0r-21,70v46,-9,88,12,88,55v0,63,-76,110,-150,93r0,-22v56,20,125,-28,119,-69v4,-42,-62,-44,-93,-30r38,-121r106,0"},"6":{"d":"195,-229v-63,22,-101,47,-125,103v32,-28,114,-22,114,42v0,98,-160,129,-160,18v0,-84,97,-172,168,-183xm152,-82v0,-55,-56,-44,-89,-21v-18,39,-7,87,32,87v33,0,57,-25,57,-66"},"7":{"d":"216,-233r-4,28v-50,54,-114,138,-141,208r-36,9v23,-67,104,-178,153,-222r-129,1r10,-24r147,0"},"8":{"d":"202,-195v0,30,-27,57,-63,70v21,9,46,24,45,49v0,44,-36,82,-93,82v-43,0,-71,-25,-71,-57v0,-39,37,-64,66,-74v-64,-35,-25,-115,54,-114v37,0,62,20,62,44xm174,-191v0,-48,-92,-28,-92,15v0,18,10,29,39,41v38,-18,53,-36,53,-56xm94,-15v45,0,73,-36,55,-72v-7,-8,-18,-15,-47,-29v-33,15,-53,34,-53,65v0,22,18,36,45,36"},"9":{"d":"202,-168v0,90,-100,180,-182,187r-11,-18v63,-13,120,-48,144,-104v-37,34,-112,23,-112,-45v0,-97,161,-136,161,-20xm160,-125v18,-40,15,-93,-30,-93v-33,0,-57,27,-57,68v0,58,53,51,87,25"},":":{"d":"87,-134v0,14,-11,25,-24,25v-14,0,-24,-11,-24,-25v0,-13,11,-24,24,-24v14,0,24,11,24,24xm63,-20v0,14,-11,25,-24,25v-14,0,-24,-11,-24,-25v0,-13,11,-24,24,-24v14,0,24,11,24,24","w":106},";":{"d":"87,-134v0,14,-11,25,-24,25v-14,0,-24,-11,-24,-25v0,-13,11,-24,24,-24v14,0,24,11,24,24xm42,-45v38,0,28,52,4,73v-10,8,-24,19,-34,23r-9,-15v15,-7,27,-19,31,-32v-11,0,-19,-11,-19,-23v0,-16,12,-26,27,-26","w":111},"<":{"d":"122,-184r-75,77r39,77r-25,15r-49,-93r88,-93","w":115},"=":{"d":"220,-149r-5,24r-188,0r5,-24r188,0xm208,-93r-5,24r-188,0r5,-24r188,0","w":224},">":{"d":"113,-108r-88,93r-22,-17r76,-79r-40,-75r25,-15","w":115},"?":{"d":"110,-250v76,0,63,75,8,107v-28,16,-35,36,-35,63r-24,0v-1,-31,8,-58,41,-79v24,-15,34,-28,34,-40v0,-40,-52,-30,-80,-10r-9,-19v21,-14,44,-22,65,-22xm82,-19v0,13,-10,22,-22,22v-12,0,-21,-10,-21,-22v0,-12,9,-22,21,-22v12,0,22,10,22,22","w":156},"@":{"d":"304,-100v0,64,-37,105,-78,105v-33,0,-40,-23,-37,-42v-20,41,-94,62,-98,-14v-4,-74,66,-139,139,-101r-22,99v-6,29,-1,39,19,39v29,0,52,-38,52,-86v0,-59,-46,-106,-114,-106v-73,0,-116,65,-116,133v0,86,77,132,159,106r4,19v-96,26,-189,-19,-189,-125v0,-85,58,-152,142,-152v78,0,139,49,139,125xm202,-139v-54,-23,-86,44,-86,90v0,21,7,28,22,28v17,0,42,-16,49,-50","w":326},"A":{"d":"185,0r-32,0r-8,-76r-92,0r-40,76r-31,0r135,-247r39,0xm143,-100r-13,-122r-64,122r77,0","w":202},"B":{"d":"192,-78v0,51,-41,82,-114,78r-64,0r53,-247r64,0v106,-3,92,100,19,116v30,5,42,26,42,53xm73,-141v50,2,102,0,100,-47v6,-35,-44,-36,-83,-34xm48,-24v58,3,112,0,112,-54v8,-38,-49,-41,-92,-38","w":210},"C":{"d":"26,-85v0,-95,97,-214,190,-145r-17,19v-76,-56,-143,50,-143,127v0,63,65,79,110,47r11,21v-64,40,-151,20,-151,-69","w":199},"D":{"d":"67,-247v88,-5,154,3,149,91v-5,77,-47,161,-137,156r-65,0xm76,-24v78,9,105,-77,108,-128v3,-62,-31,-77,-93,-71r-42,199r27,0","w":225},"E":{"d":"202,-247r-9,25r-102,0r-16,81r84,0r-6,25r-84,0r-19,90r108,0r-5,26r-139,0r53,-247r135,0","w":180},"F":{"d":"197,-247r-10,25r-96,0r-16,81r79,0r-6,24r-79,0r-25,117r-30,0r53,-247r130,0","w":155},"G":{"d":"26,-84v0,-78,50,-168,134,-165v26,0,46,8,62,23r-15,18v-17,-13,-32,-17,-51,-17v-68,-2,-96,82,-98,142v-2,59,57,76,101,53r16,-75r-49,0r0,-24r82,0r-24,115v-20,12,-49,19,-74,19v-53,0,-84,-39,-84,-89","w":227},"H":{"d":"229,-247r-52,247r-30,0r26,-120r-104,0r-26,120r-29,0r53,-247r29,0r-22,103r104,0r22,-103r29,0","w":227},"I":{"d":"96,-247r-53,247r-29,0r53,-247r29,0","w":93},"J":{"d":"96,-247r-43,205v-10,53,-26,73,-70,88r-10,-18v33,-15,40,-23,50,-69r44,-206r29,0","w":94},"K":{"d":"224,-239r-117,110r72,125r-31,9r-75,-136r129,-124xm97,-247r-53,247r-30,0r53,-247r30,0","w":198},"L":{"d":"147,-25r-9,25r-124,0r53,-247r29,0r-47,222r98,0","w":163},"M":{"d":"278,-247r-31,247r-30,0r32,-223r-110,223r-26,0r-13,-224r-64,224r-29,0r74,-247r44,0r11,205v31,-77,65,-134,99,-205r43,0","w":290},"N":{"d":"231,-247r-52,247r-31,0r-48,-151v-9,-30,-15,-60,-15,-60v-7,50,-29,154,-40,211r-31,0r53,-247r34,0r49,158v8,24,12,52,12,52r40,-210r29,0","w":228},"O":{"d":"26,-83v0,-87,40,-168,130,-168v49,0,78,30,78,83v0,84,-39,174,-131,173v-51,0,-77,-34,-77,-88xm109,-18v71,0,93,-87,93,-153v0,-35,-16,-57,-51,-57v-73,0,-93,74,-93,152v0,40,19,58,51,58","w":243},"P":{"d":"206,-190v2,68,-57,102,-142,92r-21,98r-29,0r53,-247r64,0v57,0,75,27,75,57xm111,-122v41,2,60,-32,63,-61v4,-37,-41,-42,-84,-39r-21,100r42,0","w":196},"Q":{"d":"26,-83v0,-85,41,-169,131,-168v49,0,77,30,77,83v0,71,-28,144,-87,166v24,9,43,30,81,24r-9,19v-40,19,-83,-34,-117,-36v-50,-3,-76,-35,-76,-88xm110,-18v71,0,92,-87,92,-153v0,-35,-15,-57,-50,-57v-73,-1,-93,87,-93,152v0,40,19,58,51,58","w":243},"R":{"d":"198,-189v-4,47,-38,79,-85,78v19,16,49,71,59,107r-26,8v-11,-30,-35,-79,-51,-100v-9,-13,-15,-15,-27,-15r-24,111r-30,0r53,-247v64,-2,136,-2,131,58xm72,-130v54,5,92,-9,95,-54v3,-38,-36,-40,-76,-38","w":192},"S":{"d":"201,-231r-16,22v-32,-32,-106,-22,-110,22v-2,29,34,40,57,51v78,37,40,141,-60,141v-27,0,-48,-7,-68,-20r14,-23v35,34,123,21,123,-31v0,-56,-108,-44,-97,-112v-5,-67,109,-92,157,-50","w":198},"T":{"d":"205,-247r-7,25r-67,0r-47,222r-29,0r48,-222r-67,0r6,-25r163,0","w":163},"U":{"d":"229,-247r-36,172v-10,60,-38,77,-97,79v-53,2,-78,-30,-66,-85r35,-166r29,0r-39,196v-4,37,73,36,91,15v9,-11,13,-19,18,-42r36,-169r29,0","w":225},"V":{"d":"235,-247r-137,247r-29,0r-31,-247r31,0r18,158v3,22,3,49,3,56r113,-214r32,0","w":204},"W":{"d":"316,-247r-109,247r-39,0r1,-207r-87,207r-38,0r-6,-247r30,0r1,144v0,29,-2,52,-3,76r94,-220r33,0r2,143v0,30,0,60,-2,77r92,-220r31,0","w":285},"X":{"d":"204,-247r-90,118r52,129r-34,0r-39,-106r-79,106r-36,0r104,-132r-44,-115r33,0r32,90r65,-90r36,0","w":173},"Y":{"d":"225,-247r-112,151r-21,96r-30,0r20,-98r-47,-149r34,0r34,122r87,-122r35,0","w":190},"Z":{"d":"200,-224r-161,199r119,0r-9,25r-148,0r0,-23r166,-199r-118,0r10,-25r141,0r0,23","w":184},"[":{"d":"130,-264r-5,22r-33,0r-59,277r34,0r-5,21r-59,0r68,-320r59,0","w":99},"\\":{"d":"119,8r-25,6r-50,-277r25,-5","w":146},"]":{"d":"105,-264r-68,320r-60,0r5,-21r33,0r59,-277r-33,0r4,-22r60,0","w":99},"^":{"d":"207,-99r-26,0r-38,-126r-91,126r-27,0r114,-156r21,0","w":226},"_":{"d":"156,27r-4,18r-180,0r4,-18r180,0","w":179},"\u2018":{"d":"109,-240v-15,7,-27,19,-31,32v11,0,19,10,19,22v0,16,-12,27,-27,27v-38,0,-28,-53,-4,-74v10,-8,24,-19,34,-23","w":93},"a":{"d":"15,-54v0,-82,78,-165,159,-116r-25,112v-6,30,-2,38,7,48r-23,17v-11,-11,-14,-21,-13,-39v-22,44,-105,57,-105,-22xm143,-157v-62,-26,-99,50,-99,104v0,24,9,32,26,32v19,0,40,-18,53,-43","w":187},"b":{"d":"186,-124v-3,65,-36,126,-100,128v-22,0,-50,-6,-69,-22r40,-181v4,-21,5,-43,1,-55r30,-11v8,32,-6,88,-16,119v28,-46,118,-57,114,22xm86,-19v48,-2,68,-64,69,-105v0,-21,-9,-34,-29,-34v-19,0,-39,15,-59,41r-18,87v9,8,20,11,37,11","w":202},"c":{"d":"19,-57v0,-78,70,-160,143,-112r-13,22v-58,-41,-100,30,-100,90v0,49,53,47,77,19r11,18v-40,40,-118,33,-118,-37","w":158},"d":{"d":"19,-58v0,-70,63,-151,142,-118r18,-87r28,5r-43,200v-6,30,-3,37,6,48r-25,18v-9,-9,-14,-19,-13,-39v-29,49,-113,49,-113,-27xm155,-152v-62,-31,-106,38,-106,96v0,23,9,35,26,35v21,0,44,-12,62,-43"},"e":{"d":"19,-61v0,-56,40,-124,99,-123v34,0,52,18,52,46v0,52,-54,61,-117,57v-8,32,6,62,33,62v22,0,36,-6,53,-21r12,17v-33,40,-132,40,-132,-38xm58,-102v45,0,82,1,83,-35v0,-14,-7,-25,-27,-25v-23,0,-47,23,-56,60","w":179},"f":{"d":"152,-252r-10,22v-23,-16,-54,-11,-58,23r-5,28r50,0r-13,21r-41,0v-20,75,-22,179,-60,233r-23,-13v34,-53,36,-150,55,-220r-19,0r4,-21r19,0v6,-45,19,-82,66,-82v15,0,26,3,35,9","w":99},"g":{"d":"19,-57v0,-90,90,-162,170,-112v-34,83,-9,242,-130,242v-22,0,-40,-4,-63,-16r10,-22v42,23,110,26,117,-30r8,-33v-31,46,-112,45,-112,-29xm157,-154v-63,-28,-108,41,-108,96v0,27,11,37,29,37v21,0,41,-11,60,-43"},"h":{"d":"143,-183v32,1,40,24,34,54r-27,129r-28,0r29,-139v0,-13,-8,-20,-20,-20v-17,0,-43,16,-64,42r-25,117r-28,0r43,-198v5,-24,5,-43,1,-56r30,-11v7,31,-6,88,-16,120v21,-27,50,-38,71,-38","w":200},"i":{"d":"102,-235v0,12,-10,22,-22,22v-12,0,-22,-9,-22,-21v0,-12,10,-23,22,-23v12,0,22,10,22,22xm83,-183r-39,183r-30,0r39,-179","w":94},"j":{"d":"101,-238v0,12,-10,22,-22,22v-12,0,-22,-9,-22,-21v0,-13,10,-23,22,-23v12,0,22,10,22,22xm82,-184r-38,179v-10,45,-26,64,-58,76r-10,-18v24,-10,32,-22,40,-59r36,-172","w":93},"k":{"d":"178,-171r-80,70r61,95r-28,11r-65,-109r92,-83xm88,-265v4,12,3,35,-2,59r-44,206r-28,0r43,-199v4,-20,5,-43,1,-55","w":165},"l":{"d":"88,-265v6,82,-30,160,-39,238v0,9,8,10,15,8r2,19v-26,12,-56,-2,-44,-33v10,-70,42,-145,36,-221","w":93},"m":{"d":"235,-184v30,1,37,27,31,56r-28,128r-28,0r28,-143v0,-10,-5,-15,-17,-15v-14,0,-38,17,-57,40r-25,118r-28,0r29,-143v0,-9,-3,-15,-14,-15v-14,0,-39,14,-60,41r-25,117r-27,0r28,-129v5,-23,5,-29,1,-43r26,-13v5,12,6,26,2,40v25,-29,49,-38,67,-38v22,0,30,15,30,38v24,-28,49,-39,67,-39","w":288},"n":{"d":"141,-183v26,-1,39,20,34,47r-29,136r-28,0r29,-141v0,-12,-7,-18,-18,-18v-14,0,-38,12,-62,42r-25,117r-28,0v8,-54,35,-114,29,-172r26,-13v4,12,7,22,2,40v19,-26,47,-38,70,-38","w":196},"o":{"d":"177,-120v0,69,-41,125,-100,125v-39,0,-60,-24,-60,-65v0,-71,42,-125,99,-125v42,0,61,26,61,65xm146,-123v0,-28,-16,-39,-35,-39v-40,0,-63,46,-63,104v0,28,12,39,35,39v41,0,63,-49,63,-104","w":191},"p":{"d":"183,-125v0,76,-60,158,-140,120r-16,74r-29,6r44,-204v5,-24,5,-31,1,-43r26,-13v4,10,6,20,3,38v35,-50,111,-52,111,22xm85,-19v48,-1,68,-58,68,-104v0,-62,-61,-32,-86,5r-19,88v9,8,22,11,37,11","w":199},"q":{"d":"19,-57v0,-91,89,-162,169,-112r-52,236r-28,6r22,-101v-31,46,-111,46,-111,-29xm156,-156v-64,-26,-107,42,-107,98v0,27,10,37,28,37v21,0,41,-11,60,-43","w":200},"r":{"d":"141,-182r-12,30v-29,-5,-41,11,-63,40r-24,112r-28,0v8,-53,34,-117,28,-172r27,-13v5,13,5,22,1,43v22,-29,41,-48,71,-40","w":127},"s":{"d":"154,-173r-12,22v-23,-18,-80,-19,-83,13v-2,21,26,28,43,35v71,28,31,108,-41,108v-23,0,-46,-6,-62,-17r12,-22v25,23,95,25,97,-13v3,-42,-87,-36,-79,-84v-5,-50,84,-70,125,-42","w":164},"t":{"d":"125,-179r-11,21r-39,0r-25,125v-3,21,23,19,37,14r0,18v-23,12,-68,11,-65,-22v4,-47,18,-91,26,-135r-24,0r4,-21r24,0r13,-46r30,-6v-5,13,-11,37,-14,52r44,0","w":106},"u":{"d":"185,-182r-27,127v-6,27,-4,33,5,45r-22,18v-10,-10,-15,-21,-13,-40v-22,27,-47,38,-69,38v-35,0,-41,-30,-35,-62r26,-122r29,-5r-28,144v0,16,4,21,17,21v18,0,45,-15,64,-46r25,-113","w":196},"v":{"d":"183,-179r-106,181r-28,0r-26,-180r28,-6r19,154v24,-50,55,-100,81,-149r32,0","w":162},"w":{"d":"260,-179r-90,180r-26,0r-12,-145v-20,50,-48,97,-71,145r-26,0r-12,-179r29,-6v3,48,-2,104,5,148v19,-45,48,-98,69,-143r30,0r8,145r65,-145r31,0","w":242},"x":{"d":"161,-179r-70,80r47,99r-33,0r-32,-77r-65,77r-34,0r88,-99r-38,-80r34,0r23,59r47,-59r33,0","w":144},"y":{"d":"179,-179r-83,152v-32,56,-36,86,-90,101r-7,-19v29,-7,42,-23,55,-55r-12,1v-1,-58,-12,-123,-19,-178r30,-6r12,115v3,17,-1,45,2,44r80,-155r32,0","w":162},"z":{"d":"149,-157r-125,135r99,0r-13,22r-121,0r0,-22r125,-135r-84,0r0,-22r119,0r0,22","w":144},"{":{"d":"147,-264r-5,22v-56,-9,-45,55,-57,92v-10,33,-31,43,-41,47v8,1,30,10,22,46r-14,63v-8,23,7,33,31,29r-5,21v-37,3,-60,-5,-53,-45v5,-32,32,-100,-9,-104r5,-21v38,-1,43,-68,53,-105v10,-39,32,-49,73,-45","w":115},"|":{"d":"96,-272r-59,278r-24,0r59,-278r24,0","w":88},"}":{"d":"108,-114r-5,21v-38,-1,-44,67,-53,104v-10,39,-32,49,-73,45r5,-21v55,9,45,-54,57,-92v11,-37,32,-44,41,-47v-8,-2,-29,-14,-22,-46r14,-63v8,-23,-7,-33,-31,-29r4,-22v37,-3,60,4,54,45v-5,33,-32,100,9,105","w":115},"~":{"d":"77,-133v28,1,46,24,73,24v16,0,27,-12,36,-25r8,17v-14,15,-30,32,-52,32v-27,-1,-46,-24,-73,-24v-16,0,-28,12,-36,25r-8,-18v14,-15,30,-31,52,-31","w":215},"\u00a1":{"d":"89,-158v0,12,-10,22,-22,22v-12,0,-22,-9,-22,-21v0,-13,10,-23,22,-23v12,0,22,10,22,22xm67,-106r-30,175r-37,5r46,-180r21,0","w":102},"\u00a2":{"d":"163,-165r-19,20v-8,-8,-14,-12,-21,-13r-30,139v12,-3,23,-9,33,-19r11,18v-17,14,-32,21,-49,23r-6,28r-19,0r5,-27v-82,-3,-44,-148,-2,-168v14,-12,27,-17,42,-19r6,-28r20,0r-6,28v17,2,26,9,35,18xm103,-158v-33,11,-42,36,-51,77v-8,36,-1,57,21,62","w":159},"\u00a3":{"d":"224,-237r-22,21v-35,-37,-94,-8,-97,45r-6,28r59,0r-5,24r-59,0r-19,91r89,0r-6,28r-158,0r6,-28r39,0r19,-91r-34,0r5,-24r34,0v6,-91,89,-153,155,-94","w":194},"\u00a5":{"d":"225,-247r-84,112r54,0r-5,22r-64,0v-8,9,-15,19,-17,34r74,0r-4,21r-75,0r-12,58r-30,0r12,-58r-70,0r5,-21r69,0v4,-12,5,-24,-1,-34r-61,0r5,-22r50,0r-36,-112r33,0r34,122r86,-122r37,0","w":190},"\u0192":{"d":"165,-250r-14,20v-23,-17,-50,-10,-56,23r-6,28r49,0r-14,21r-39,0r-32,138v-11,49,-14,66,-61,91r-10,-20v35,-20,34,-35,42,-68r33,-141r-17,0r3,-21r18,0v5,-58,53,-105,104,-71","w":100},"\u00a7":{"d":"192,-228r-27,14v-8,-37,-87,-23,-81,14v7,42,85,42,85,90v0,26,-19,45,-42,57v42,40,5,106,-70,105v-31,0,-56,-13,-61,-44r27,-12v3,22,18,30,42,30v31,0,47,-17,47,-39v-10,-44,-85,-35,-86,-88v0,-30,22,-48,48,-60v-50,-34,4,-101,59,-101v27,0,53,10,59,34xm140,-103v0,-26,-30,-32,-47,-44v-36,4,-54,52,-15,66r29,16v15,-6,33,-21,33,-38","w":186},"\u00a4":{"d":"240,-233r-10,25v-45,-43,-113,-1,-126,52r97,0r-5,22r-100,0v-3,10,-4,19,-6,29r100,0r-5,21r-96,0v-1,36,14,64,58,64v18,0,33,-6,51,-16r0,26v-15,8,-37,14,-61,14v-51,0,-79,-39,-79,-88r-40,0r5,-21r37,0v1,-10,3,-20,6,-29r-37,0r4,-22r40,0v19,-76,107,-118,167,-77","w":227},"'":{"d":"94,-255r-18,87r-26,0r18,-87r26,0","w":90},"\u201c":{"d":"180,-240v-15,7,-27,19,-31,32v11,0,19,10,19,22v0,16,-12,27,-27,27v-37,0,-26,-52,-4,-74v12,-11,24,-19,34,-23xm109,-240v-15,7,-27,19,-31,32v11,0,19,10,19,22v0,16,-12,27,-27,27v-38,0,-27,-52,-4,-74v12,-11,24,-19,34,-23","w":164},"\u00ab":{"d":"180,-149r-62,65r32,63r-22,12r-39,-79r72,-75xm113,-149r-62,65r32,63r-22,12r-39,-79r72,-75","w":183},"\u2013":{"d":"198,-111r-4,21r-175,0r5,-21r174,0","w":210},"\u00b7":{"d":"80,-100v0,13,-11,23,-24,23v-13,0,-24,-10,-24,-23v0,-13,11,-24,24,-24v13,0,24,11,24,24","w":105},"\u00b6":{"d":"217,-255r-64,300r-26,0r59,-276r-42,0r-59,276r-26,0r34,-159v-39,0,-62,-22,-62,-53v0,-53,44,-88,99,-88r87,0","w":213},"\u2022":{"d":"166,-127v0,35,-28,63,-63,63v-35,0,-64,-28,-64,-63v0,-35,29,-64,64,-64v35,0,63,29,63,64","w":187},"\u201d":{"d":"147,-251v36,0,28,52,4,73v-10,8,-24,19,-34,23r-9,-16v15,-7,27,-19,31,-32v-11,0,-19,-10,-19,-22v0,-16,12,-26,27,-26xm76,-251v36,0,28,52,4,73v-10,8,-24,19,-34,23r-10,-16v15,-7,27,-19,31,-32v-11,0,-18,-10,-18,-22v0,-16,12,-26,27,-26","w":165},"\u00bb":{"d":"163,-85r-71,76r-20,-15r63,-65r-32,-63r22,-11xm96,-85r-71,76r-20,-15r63,-65r-32,-63r22,-11","w":184},"\u2026":{"d":"229,-20v0,14,-11,25,-24,25v-14,0,-24,-11,-24,-25v0,-13,11,-24,24,-24v14,0,24,11,24,24xm147,-20v0,14,-12,25,-25,25v-14,0,-24,-11,-24,-25v0,-13,11,-24,24,-24v14,0,25,11,25,24xm64,-20v0,14,-11,25,-24,25v-14,0,-25,-11,-25,-25v0,-13,11,-24,24,-24v14,0,25,11,25,24","w":276},"\u00bf":{"d":"119,-158v0,12,-10,22,-22,22v-12,0,-22,-9,-22,-21v0,-13,10,-23,22,-23v12,0,22,10,22,22xm113,51v-36,30,-119,33,-118,-22v0,-21,14,-41,45,-62v27,-18,35,-37,35,-64r24,0v1,31,-8,58,-41,79v-24,15,-34,28,-34,40v0,40,52,29,79,10","w":155},"`":{"d":"132,-220r-9,17r-80,-36r15,-28","w":114},"\u00b4":{"d":"138,-239r-81,36r-10,-17r75,-47","w":122},"\u00af":{"d":"144,-265r-4,19r-99,0r5,-19r98,0","w":113},"\u00a8":{"d":"159,-224v0,10,-8,20,-18,20v-26,0,-23,-39,0,-38v10,0,18,8,18,18xm85,-224v0,10,-8,20,-18,20v-22,0,-26,-39,-1,-38v10,0,19,8,19,18","w":148},"\u00b8":{"d":"49,41v-3,24,-49,40,-70,21r12,-17v19,18,54,-15,24,-15v-6,0,-14,1,-14,1r17,-35r21,2r-8,17v18,3,19,13,18,26","w":86},"\u2014":{"d":"280,-111r-5,21r-256,0r5,-21r256,0","w":292},"\u00c6":{"d":"313,-247r-9,25r-99,0r-17,81r85,0r-6,25r-84,0r-20,90r109,0r-6,26r-138,0r16,-76r-81,0r-63,76r-36,0r205,-247r144,0xm173,-215r-91,115r67,0","w":291},"\u00aa":{"d":"40,-176v0,-64,60,-125,123,-88r-19,85v-5,22,-3,28,5,36r-18,14v-8,-8,-12,-16,-12,-27v-20,31,-79,39,-79,-20xm140,-106r-4,20r-113,0r5,-20r112,0xm136,-252v-46,-17,-74,37,-72,76v0,17,7,23,19,23v14,0,30,-13,39,-32","w":154},"\u0141":{"d":"147,-25r-9,25r-124,0r24,-111r-26,8r6,-26r26,-8r23,-110r29,0r-21,101r69,-21r-6,26r-69,21r-20,95r98,0","w":163},"\u00d8":{"d":"6,-83v0,-87,40,-168,130,-168v21,0,39,6,52,17r32,-39r17,12r-35,42v8,13,12,30,12,51v0,84,-39,174,-131,173v-21,0,-37,-7,-50,-17r-33,41r-16,-11r36,-45v-9,-14,-14,-33,-14,-56xm131,-228v-78,4,-97,93,-90,175r129,-159v-8,-10,-21,-16,-39,-16xm90,-18v75,-3,94,-100,90,-174r-130,159v9,10,23,15,40,15","w":237},"\u0152":{"d":"333,-247r-9,25r-101,0r-17,81r84,0r-5,25r-85,0r-19,90r109,0r-6,26v-78,-6,-186,17,-234,-19v-51,-39,-8,-172,28,-196v53,-55,160,-24,255,-32xm192,-219v-41,-5,-77,-1,-97,23v-32,38,-68,168,14,172v10,0,29,0,42,-2","w":311},"\u00ba":{"d":"164,-225v0,53,-31,94,-76,94v-30,0,-47,-19,-47,-50v0,-54,32,-94,76,-94v32,0,47,20,47,50xm139,-106r-4,20r-113,0r4,-20r113,0xm139,-228v0,-20,-13,-27,-26,-27v-30,0,-46,33,-46,75v0,21,9,30,25,30v30,0,47,-37,47,-78","w":155},"\u00e6":{"d":"268,-139v-3,52,-53,62,-116,58v-10,31,6,62,33,62v22,0,36,-5,53,-20r11,17v-24,30,-101,41,-122,-3v-28,45,-114,38,-112,-16v0,-18,6,-35,30,-50v28,-18,80,-14,86,-13v7,-22,17,-58,-18,-57v-17,0,-38,6,-61,21r-10,-20v38,-23,101,-41,120,2v27,-37,109,-37,106,19xm156,-102v45,0,82,1,83,-35v0,-14,-7,-25,-27,-25v-23,0,-47,23,-56,60xm127,-84v-6,0,-42,-2,-60,6v-30,13,-30,62,4,62v36,0,51,-36,56,-68","w":277},"\u0131":{"d":"83,-183r-39,183r-30,0r39,-179","w":94},"\u0142":{"d":"102,-155r-6,26r-28,9r-19,93v0,9,8,10,15,8r2,19v-26,12,-51,0,-44,-33r16,-77r-23,7r6,-26r23,-7v6,-33,22,-85,14,-118r30,-11v9,34,-9,85,-14,119","w":93},"\u00f8":{"d":"193,-193r-27,33v40,81,-37,205,-126,155r-24,29r-15,-11r26,-31v-36,-84,36,-200,126,-156r24,-29xm135,-152v-53,-33,-95,36,-87,107xm57,-26v56,35,99,-42,88,-108","w":191},"\u0153":{"d":"288,-138v0,53,-54,61,-116,57v-8,32,6,62,33,62v22,0,36,-6,53,-21r12,17v-25,31,-104,42,-124,-3v-33,47,-129,46,-129,-33v0,-71,42,-124,99,-124v28,0,46,12,55,31v30,-42,117,-47,117,14xm177,-102v45,0,82,1,83,-35v0,-14,-7,-25,-27,-25v-23,0,-47,23,-56,60xm146,-121v0,-28,-16,-39,-35,-39v-40,0,-63,45,-63,103v0,28,12,40,35,40v41,0,63,-49,63,-104","w":298},"\u00df":{"d":"188,-209v0,54,-68,54,-68,66v0,14,61,16,61,71v0,49,-59,93,-116,70r9,-20v34,17,79,-4,79,-43v0,-49,-59,-39,-59,-74v0,-33,64,-24,64,-69v0,-15,-11,-26,-30,-26v-26,0,-41,18,-50,55v-20,83,-24,193,-64,254r-23,-13v33,-54,37,-150,56,-220r-27,0r5,-21r26,0v9,-53,40,-76,83,-76v33,0,54,19,54,46","w":203},"\u0178":{"d":"189,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,9,-19,19,-19v10,0,18,9,18,19xm115,-281v0,10,-9,19,-19,19v-10,0,-18,-9,-18,-19v0,-10,8,-19,18,-19v10,0,19,9,19,19xm225,-247r-112,151r-21,96r-30,0r20,-98r-47,-149r34,0r34,122r87,-122r35,0","w":190},"\u2122":{"d":"324,-247r-18,154r-25,0r14,-115r-58,115r-21,0r-10,-117r-34,117r-24,0r46,-154r32,0r9,111r56,-111r33,0xm155,-247r-6,21r-42,0r-28,133r-24,0r27,-133r-41,0r4,-21r110,0","w":336},"\u017e":{"d":"166,-249r-71,48r-52,-48r13,-16r43,30r55,-30xm149,-157r-125,135r99,0r-13,22r-121,0r0,-22r125,-135r-84,0r0,-22r119,0r0,22","w":144},"\u017d":{"d":"197,-311r-71,49r-51,-49r12,-16r44,31r55,-31xm200,-224r-161,199r119,0r-9,25r-148,0r0,-23r166,-199r-118,0r10,-25r141,0r0,23","w":184},"\u0161":{"d":"171,-249r-71,48r-52,-48r13,-16r43,30r55,-30xm154,-173r-12,22v-23,-18,-80,-19,-83,13v-2,21,26,28,43,35v71,28,31,108,-41,108v-23,0,-46,-6,-62,-17r12,-22v25,23,95,25,97,-13v3,-42,-87,-36,-79,-84v-5,-50,84,-70,125,-42","w":164},"\u0160":{"d":"199,-311r-71,49r-52,-49r13,-16r43,31r56,-31xm201,-231r-16,22v-32,-32,-106,-22,-110,22v-2,29,34,40,57,51v78,37,40,141,-60,141v-27,0,-48,-7,-68,-20r14,-23v35,34,123,21,123,-31v0,-56,-108,-44,-97,-112v-5,-67,109,-92,157,-50","w":198},"\u00ff":{"d":"162,-224v0,10,-9,20,-19,20v-26,0,-23,-39,0,-38v10,0,19,8,19,18xm87,-224v0,10,-8,20,-18,20v-22,0,-26,-39,-1,-38v10,0,19,8,19,18xm179,-179r-83,152v-32,56,-36,86,-90,101r-7,-19v29,-7,42,-23,55,-55r-12,1v-1,-58,-12,-123,-19,-178r30,-6r12,115v3,17,-1,45,2,44r80,-155r32,0","w":162},"\u00fe":{"d":"186,-124v-3,80,-57,151,-143,121r-16,72r-29,6r59,-274v5,-21,5,-43,1,-55r30,-11v8,32,-6,88,-16,119v28,-46,117,-57,114,22xm86,-19v48,-2,68,-64,69,-105v0,-21,-9,-34,-29,-34v-19,0,-39,15,-59,41r-18,87v9,8,20,11,37,11","w":202},"\u00fd":{"d":"161,-239r-81,36r-10,-17r75,-47xm179,-179r-83,152v-32,56,-36,86,-90,101r-7,-19v29,-7,42,-23,55,-55r-12,1v-1,-58,-12,-123,-19,-178r30,-6r12,115v3,17,-1,45,2,44r80,-155r32,0","w":162},"\u00fc":{"d":"182,-224v0,10,-8,20,-18,20v-22,0,-26,-39,-1,-38v10,0,19,8,19,18xm108,-224v0,10,-9,20,-19,20v-25,0,-22,-39,0,-38v10,0,19,8,19,18xm185,-182r-27,127v-6,27,-4,33,5,45r-22,18v-10,-10,-15,-21,-13,-40v-22,27,-47,38,-69,38v-35,0,-41,-30,-35,-62r26,-122r29,-5r-28,144v0,16,4,21,17,21v18,0,45,-15,64,-46r25,-113","w":196},"\u00fb":{"d":"185,-218r-13,16r-43,-31r-56,31r-11,-16r71,-48xm185,-182r-27,127v-6,27,-4,33,5,45r-22,18v-10,-10,-15,-21,-13,-40v-22,27,-47,38,-69,38v-35,0,-41,-30,-35,-62r26,-122r29,-5r-28,144v0,16,4,21,17,21v18,0,45,-15,64,-46r25,-113","w":196},"\u00fa":{"d":"191,-239r-81,36r-10,-17r75,-47xm185,-182r-27,127v-6,27,-4,33,5,45r-22,18v-10,-10,-15,-21,-13,-40v-22,27,-47,38,-69,38v-35,0,-41,-30,-35,-62r26,-122r29,-5r-28,144v0,16,4,21,17,21v18,0,45,-15,64,-46r25,-113","w":196},"\u00f9":{"d":"160,-220r-10,17r-80,-36r16,-28xm185,-182r-27,127v-6,27,-4,33,5,45r-22,18v-10,-10,-15,-21,-13,-40v-22,27,-47,38,-69,38v-35,0,-41,-30,-35,-62r26,-122r29,-5r-28,144v0,16,4,21,17,21v18,0,45,-15,64,-46r25,-113","w":196},"\u00f7":{"d":"149,-170v0,14,-11,25,-24,25v-13,0,-24,-11,-24,-24v0,-14,11,-25,25,-25v13,0,23,11,23,24xm203,-108r-5,23r-180,0r5,-23r180,0xm121,-20v0,14,-11,24,-25,24v-13,0,-24,-11,-24,-24v0,-14,11,-24,25,-24v13,0,24,11,24,24","w":216},"\u00f6":{"d":"178,-224v0,10,-8,20,-18,20v-22,0,-26,-39,-1,-38v10,0,19,8,19,18xm104,-224v0,10,-9,20,-19,20v-25,0,-22,-39,0,-38v10,0,19,8,19,18xm177,-120v0,69,-41,125,-100,125v-39,0,-60,-24,-60,-65v0,-71,42,-125,99,-125v42,0,61,26,61,65xm146,-123v0,-28,-16,-39,-35,-39v-40,0,-63,46,-63,104v0,28,12,39,35,39v41,0,63,-49,63,-104","w":191},"\u00f5":{"d":"188,-236v-15,15,-28,23,-49,23v-28,0,-49,-26,-70,0r-7,-16v15,-15,27,-23,48,-23v22,0,22,14,43,14v12,0,19,-6,28,-14xm177,-120v0,69,-41,125,-100,125v-39,0,-60,-24,-60,-65v0,-71,42,-125,99,-125v42,0,61,26,61,65xm146,-123v0,-28,-16,-39,-35,-39v-40,0,-63,46,-63,104v0,28,12,39,35,39v41,0,63,-49,63,-104","w":191},"\u00f4":{"d":"181,-218r-13,16r-43,-31r-55,31r-11,-16r71,-48xm177,-120v0,69,-41,125,-100,125v-39,0,-60,-24,-60,-65v0,-71,42,-125,99,-125v42,0,61,26,61,65xm146,-123v0,-28,-16,-39,-35,-39v-40,0,-63,46,-63,104v0,28,12,39,35,39v41,0,63,-49,63,-104","w":191},"\u00f3":{"d":"186,-239r-81,36r-9,-17r75,-47xm177,-120v0,69,-41,125,-100,125v-39,0,-60,-24,-60,-65v0,-71,42,-125,99,-125v42,0,61,26,61,65xm146,-123v0,-28,-16,-39,-35,-39v-40,0,-63,46,-63,104v0,28,12,39,35,39v41,0,63,-49,63,-104","w":191},"\u00f2":{"d":"154,-220r-9,17r-80,-36r15,-28xm177,-120v0,69,-41,125,-100,125v-39,0,-60,-24,-60,-65v0,-71,42,-125,99,-125v42,0,61,26,61,65xm146,-123v0,-28,-16,-39,-35,-39v-40,0,-63,46,-63,104v0,28,12,39,35,39v41,0,63,-49,63,-104","w":191},"\u00f1":{"d":"185,-236v-15,15,-28,23,-49,23v-28,0,-49,-26,-70,0r-7,-16v15,-15,27,-23,48,-23v22,0,22,14,43,14v12,0,19,-6,28,-14xm141,-183v26,-1,39,20,34,47r-29,136r-28,0r29,-141v0,-12,-7,-18,-18,-18v-14,0,-38,12,-62,42r-25,117r-28,0v8,-54,35,-114,29,-172r26,-13v4,12,7,22,2,40v19,-26,47,-38,70,-38","w":196},"\u00f0":{"d":"129,-236v79,58,57,241,-56,241v-43,0,-64,-35,-64,-72v0,-68,69,-120,133,-92v-3,-23,-14,-43,-33,-58r-23,21r-16,-13r22,-20v-12,-7,-26,-12,-42,-17r19,-17v16,4,31,10,43,16r19,-18r16,13xm143,-135v-9,-6,-26,-10,-43,-10v-37,0,-59,37,-59,78v0,26,13,49,36,49v43,0,66,-62,66,-117","w":187},"\u00ef":{"d":"128,-224v0,10,-8,20,-18,20v-22,0,-26,-39,-1,-38v10,0,19,8,19,18xm54,-224v0,10,-9,20,-19,20v-25,0,-22,-39,0,-38v10,0,19,8,19,18xm84,-183r-39,183r-31,0r39,-179","w":94},"\u00ee":{"d":"137,-218r-13,16r-43,-31r-55,31r-12,-16r71,-48xm87,-183r-39,183r-30,0r38,-179","w":94},"\u00ed":{"d":"138,-239r-81,36r-10,-17r75,-47xm84,-183r-39,183r-31,0r39,-179","w":94},"\u00ec":{"d":"104,-220r-9,17r-81,-36r16,-28xm90,-183r-39,183r-30,0r38,-179","w":94},"\u00eb":{"d":"180,-224v0,10,-8,20,-18,20v-22,0,-26,-39,-1,-38v10,0,19,8,19,18xm105,-224v0,10,-8,20,-18,20v-26,0,-23,-39,0,-38v10,0,18,8,18,18xm19,-61v0,-56,40,-124,99,-123v34,0,52,18,52,46v0,52,-54,61,-117,57v-8,32,6,62,33,62v22,0,36,-6,53,-21r12,17v-33,40,-132,40,-132,-38xm58,-102v45,0,82,1,83,-35v0,-14,-7,-25,-27,-25v-23,0,-47,23,-56,60","w":179},"\u00ea":{"d":"182,-218r-13,16r-43,-31r-56,31r-11,-16r71,-48xm19,-61v0,-56,40,-124,99,-123v34,0,52,18,52,46v0,52,-54,61,-117,57v-8,32,6,62,33,62v22,0,36,-6,53,-21r12,17v-33,40,-132,40,-132,-38xm58,-102v45,0,82,1,83,-35v0,-14,-7,-25,-27,-25v-23,0,-47,23,-56,60","w":179},"\u00e9":{"d":"190,-239r-81,36r-9,-17r75,-47xm19,-61v0,-56,40,-124,99,-123v34,0,52,18,52,46v0,52,-54,61,-117,57v-8,32,6,62,33,62v22,0,36,-6,53,-21r12,17v-33,40,-132,40,-132,-38xm58,-102v45,0,82,1,83,-35v0,-14,-7,-25,-27,-25v-23,0,-47,23,-56,60","w":179},"\u00e8":{"d":"156,-220r-10,17r-80,-36r15,-28xm19,-61v0,-56,40,-124,99,-123v34,0,52,18,52,46v0,52,-54,61,-117,57v-8,32,6,62,33,62v22,0,36,-6,53,-21r12,17v-33,40,-132,40,-132,-38xm58,-102v45,0,82,1,83,-35v0,-14,-7,-25,-27,-25v-23,0,-47,23,-56,60","w":179},"\u00e7":{"d":"19,-57v-2,-78,70,-160,143,-112r-13,22v-58,-41,-100,30,-100,90v0,49,53,47,77,19r11,18v-20,17,-38,24,-61,24r-5,11v18,3,19,13,18,26v-3,24,-49,40,-70,21r12,-17v18,19,53,-15,24,-15v-6,0,-14,1,-14,1r14,-30v-25,-7,-36,-26,-36,-58","w":158},"\u00e5":{"d":"161,-237v0,21,-17,38,-38,38v-21,0,-37,-17,-37,-38v0,-21,17,-38,38,-38v21,0,37,17,37,38xm15,-54v0,-82,78,-165,159,-116r-25,112v-6,30,-2,38,7,48r-23,17v-11,-11,-14,-21,-13,-39v-22,44,-105,57,-105,-22xm145,-237v0,-12,-10,-22,-21,-22v-12,0,-22,10,-22,22v0,12,10,21,21,21v12,0,22,-9,22,-21xm143,-157v-62,-26,-99,50,-99,104v0,24,9,32,26,32v19,0,40,-18,53,-43","w":187},"\u00e4":{"d":"183,-224v0,10,-9,20,-19,20v-26,0,-23,-39,0,-38v10,0,19,8,19,18xm108,-224v0,10,-8,20,-18,20v-22,0,-26,-39,-1,-38v10,0,19,8,19,18xm15,-54v0,-82,78,-165,159,-116r-25,112v-6,30,-2,38,7,48r-23,17v-11,-11,-14,-21,-13,-39v-22,44,-105,57,-105,-22xm143,-157v-62,-26,-99,50,-99,104v0,24,9,32,26,32v19,0,40,-18,53,-43","w":187},"\u00e3":{"d":"192,-236v-15,15,-28,23,-49,23v-22,0,-22,-14,-43,-14v-12,0,-19,6,-28,14r-6,-16v15,-15,27,-23,48,-23v22,0,22,14,43,14v12,0,19,-6,28,-14xm15,-54v0,-82,78,-165,159,-116r-25,112v-6,30,-2,38,7,48r-23,17v-11,-11,-14,-21,-13,-39v-22,44,-105,57,-105,-22xm143,-157v-62,-26,-99,50,-99,104v0,24,9,32,26,32v19,0,40,-18,53,-43","w":187},"\u00e2":{"d":"190,-218r-13,16r-43,-31r-56,31r-11,-16r71,-48xm15,-54v0,-82,78,-165,159,-116r-25,112v-6,30,-2,38,7,48r-23,17v-11,-11,-14,-21,-13,-39v-22,44,-105,57,-105,-22xm143,-157v-62,-26,-99,50,-99,104v0,24,9,32,26,32v19,0,40,-18,53,-43","w":187},"\u00e1":{"d":"188,-239r-81,36r-9,-17r75,-47xm15,-54v0,-82,78,-165,159,-116r-25,112v-6,30,-2,38,7,48r-23,17v-11,-11,-14,-21,-13,-39v-22,44,-105,57,-105,-22xm143,-157v-62,-26,-99,50,-99,104v0,24,9,32,26,32v19,0,40,-18,53,-43","w":187},"\u00e0":{"d":"163,-220r-10,17r-80,-36r16,-28xm15,-54v0,-82,78,-165,159,-116r-25,112v-6,30,-2,38,7,48r-23,17v-11,-11,-14,-21,-13,-39v-22,44,-105,57,-105,-22xm143,-157v-62,-26,-99,50,-99,104v0,24,9,32,26,32v19,0,40,-18,53,-43","w":187},"\u00de":{"d":"198,-150v1,67,-58,101,-142,91r-13,59r-29,0r53,-247r29,0r-9,40v61,-7,119,15,111,57xm102,-83v42,3,61,-31,64,-60v4,-37,-40,-43,-84,-40r-21,100r41,0","w":196},"\u00dd":{"d":"185,-297r-81,36r-9,-17r75,-47xm225,-247r-112,151r-21,96r-30,0r20,-98r-47,-149r34,0r34,122r87,-122r35,0","w":190},"\u00dc":{"d":"208,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,9,-19,19,-19v10,0,18,9,18,19xm134,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,8,-19,18,-19v10,0,19,9,19,19xm229,-247r-36,172v-10,60,-38,77,-97,79v-53,2,-78,-30,-66,-85r35,-166r29,0r-39,196v-4,37,73,36,91,15v9,-11,13,-19,18,-42r36,-169r29,0","w":225},"\u00db":{"d":"210,-275r-13,15r-43,-30r-55,30r-12,-15r71,-49xm229,-247r-36,172v-10,60,-38,77,-97,79v-53,2,-78,-30,-66,-85r35,-166r29,0r-39,196v-4,37,73,36,91,15v9,-11,13,-19,18,-42r36,-169r29,0","w":225},"\u00da":{"d":"208,-297r-81,36r-9,-17r75,-47xm229,-247r-36,172v-10,60,-38,77,-97,79v-53,2,-78,-30,-66,-85r35,-166r29,0r-39,196v-4,37,73,36,91,15v9,-11,13,-19,18,-42r36,-169r29,0","w":225},"\u00d9":{"d":"181,-278r-10,17r-80,-36r16,-28xm229,-247r-36,172v-10,60,-38,77,-97,79v-53,2,-78,-30,-66,-85r35,-166r29,0r-39,196v-4,37,73,36,91,15v9,-11,13,-19,18,-42r36,-169r29,0","w":225},"\u00d7":{"d":"163,-135r-55,45r36,45r-23,19r-35,-46r-55,46r-15,-19r55,-45r-35,-45r22,-19r36,46r55,-46","w":177},"\u00d6":{"d":"217,-282v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,8,-19,18,-19v10,0,19,9,19,19xm143,-282v0,10,-9,19,-19,19v-10,0,-19,-9,-19,-19v0,-10,9,-19,19,-19v10,0,19,9,19,19xm26,-83v0,-87,40,-168,130,-168v49,0,78,30,78,83v0,84,-39,174,-131,173v-51,0,-77,-34,-77,-88xm109,-18v71,0,93,-87,93,-153v0,-35,-16,-57,-51,-57v-73,0,-93,74,-93,152v0,40,19,58,51,58","w":243},"\u00d5":{"d":"218,-294v-15,15,-28,23,-49,23v-28,0,-49,-25,-70,1r-7,-17v15,-15,27,-22,48,-22v28,0,50,24,71,-1xm26,-83v0,-87,40,-168,130,-168v49,0,78,30,78,83v0,84,-39,174,-131,173v-51,0,-77,-34,-77,-88xm109,-18v71,0,93,-87,93,-153v0,-35,-16,-57,-51,-57v-73,0,-93,74,-93,152v0,40,19,58,51,58","w":243},"\u00d4":{"d":"216,-275r-13,15r-44,-30r-55,30r-11,-15r71,-49xm26,-83v0,-87,40,-168,130,-168v49,0,78,30,78,83v0,84,-39,174,-131,173v-51,0,-77,-34,-77,-88xm109,-18v71,0,93,-87,93,-153v0,-35,-16,-57,-51,-57v-73,0,-93,74,-93,152v0,40,19,58,51,58","w":243},"\u00d3":{"d":"214,-297r-81,36r-10,-17r75,-47xm26,-83v0,-87,40,-168,130,-168v49,0,78,30,78,83v0,84,-39,174,-131,173v-51,0,-77,-34,-77,-88xm109,-18v71,0,93,-87,93,-153v0,-35,-16,-57,-51,-57v-73,0,-93,74,-93,152v0,40,19,58,51,58","w":243},"\u00d2":{"d":"188,-278r-9,17r-81,-36r16,-28xm26,-83v0,-87,40,-168,130,-168v49,0,78,30,78,83v0,84,-39,174,-131,173v-51,0,-77,-34,-77,-88xm109,-18v71,0,93,-87,93,-153v0,-35,-16,-57,-51,-57v-73,0,-93,74,-93,152v0,40,19,58,51,58","w":243},"\u00d1":{"d":"216,-295v-15,15,-28,23,-49,23v-28,0,-49,-24,-70,1r-7,-17v15,-15,27,-22,48,-22v28,0,50,24,71,-1xm231,-247r-52,247r-31,0r-48,-151v-9,-30,-15,-60,-15,-60v-7,50,-29,154,-40,211r-31,0r53,-247r34,0r49,158v8,24,12,52,12,52r40,-210r29,0","w":228},"\u00d0":{"d":"67,-247v88,-5,154,3,149,91v-5,77,-47,161,-137,156r-65,0r25,-116r-30,0r4,-21r31,0xm76,-24v78,9,105,-77,108,-128v3,-62,-31,-77,-93,-71r-18,86r57,0r-13,21r-48,0r-20,92r27,0","w":225},"\u00cf":{"d":"138,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,9,-19,19,-19v10,0,18,9,18,19xm64,-281v0,10,-9,19,-19,19v-10,0,-18,-9,-18,-19v0,-10,8,-19,18,-19v10,0,19,9,19,19xm96,-247r-53,247r-29,0r53,-247r29,0","w":93},"\u00ce":{"d":"144,-275r-13,15r-44,-30r-55,30r-11,-15r71,-49xm96,-247r-53,247r-29,0r53,-247r29,0","w":93},"\u00cd":{"d":"149,-297r-81,36r-9,-17r75,-47xm96,-247r-53,247r-29,0r53,-247r29,0","w":93},"\u00cc":{"d":"106,-278r-9,17r-80,-36r15,-28xm96,-247r-53,247r-29,0r53,-247r29,0","w":93},"\u00cb":{"d":"194,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,8,-19,18,-19v10,0,19,9,19,19xm120,-281v0,10,-9,19,-19,19v-10,0,-19,-9,-19,-19v0,-10,9,-19,19,-19v10,0,19,9,19,19xm202,-247r-9,25r-102,0r-16,81r84,0r-6,25r-84,0r-19,90r108,0r-5,26r-139,0r53,-247r135,0","w":180},"\u00ca":{"d":"197,-275r-13,15r-43,-30r-55,30r-11,-15r70,-49xm202,-247r-9,25r-102,0r-16,81r84,0r-6,25r-84,0r-19,90r108,0r-5,26r-139,0r53,-247r135,0","w":180},"\u00c9":{"d":"191,-297r-81,36r-10,-17r75,-47xm202,-247r-9,25r-102,0r-16,81r84,0r-6,25r-84,0r-19,90r108,0r-5,26r-139,0r53,-247r135,0","w":180},"\u00c8":{"d":"173,-278r-10,17r-80,-36r16,-28xm202,-247r-9,25r-102,0r-16,81r84,0r-6,25r-84,0r-19,90r108,0r-5,26r-139,0r53,-247r135,0","w":180},"\u00c7":{"d":"26,-85v0,-95,97,-214,190,-145r-17,19v-76,-56,-143,50,-143,127v0,63,65,79,110,47r11,21v-26,14,-50,21,-79,20r-5,11v18,3,19,13,18,26v-3,24,-49,40,-70,21r12,-17v18,19,53,-15,24,-15v-6,0,-14,1,-14,1r15,-31v-33,-10,-52,-41,-52,-85","w":199},"\u00c5":{"d":"179,-295v0,21,-17,38,-38,38v-21,0,-38,-17,-38,-38v0,-21,17,-38,38,-38v21,0,38,17,38,38xm185,0r-32,0r-8,-76r-92,0r-40,76r-31,0r135,-247r39,0xm162,-295v0,-12,-10,-21,-21,-21v-12,0,-22,9,-22,21v0,12,11,22,22,22v12,0,21,-10,21,-22xm143,-100r-13,-122r-64,122r77,0","w":202},"\u00c4":{"d":"194,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,9,-19,19,-19v10,0,18,9,18,19xm120,-281v0,10,-8,19,-18,19v-10,0,-19,-9,-19,-19v0,-10,8,-19,18,-19v10,0,19,9,19,19xm185,0r-32,0r-8,-76r-92,0r-40,76r-31,0r135,-247r39,0xm143,-100r-13,-122r-64,122r77,0","w":202},"\u00c3":{"d":"199,-294v-15,15,-28,23,-49,23v-28,0,-49,-25,-70,1r-7,-17v15,-15,27,-22,48,-22v28,0,50,24,71,-1xm185,0r-32,0r-8,-76r-92,0r-40,76r-31,0r135,-247r39,0xm143,-100r-13,-122r-64,122r77,0","w":202},"\u00c2":{"d":"197,-275r-13,15r-43,-30r-56,30r-11,-15r71,-49xm185,0r-32,0r-8,-76r-92,0r-40,76r-31,0r135,-247r39,0xm143,-100r-13,-122r-64,122r77,0","w":202},"\u00c1":{"d":"197,-297r-81,36r-9,-17r75,-47xm185,0r-32,0r-8,-76r-92,0r-40,76r-31,0r135,-247r39,0xm143,-100r-13,-122r-64,122r77,0","w":202},"\u00c0":{"d":"164,-278r-9,17r-80,-36r15,-28xm185,0r-32,0r-8,-76r-92,0r-40,76r-31,0r135,-247r39,0xm143,-100r-13,-122r-64,122r77,0","w":202},"\u00b1":{"d":"161,-131r-6,25r-54,0r-10,51r-26,0r11,-51r-54,0r5,-25r54,0r10,-48r26,0r-10,48r54,0xm140,-39r-5,26r-132,0r5,-26r132,0","w":168},"\u00b0":{"d":"144,-191v0,29,-24,53,-53,53v-29,0,-53,-24,-53,-53v0,-29,25,-53,53,-53v29,0,53,24,53,53xm122,-191v0,-17,-14,-31,-30,-31v-18,0,-33,14,-33,31v0,17,16,32,32,32v17,0,31,-15,31,-32","w":136},"\u00ae":{"d":"302,-127v0,76,-61,133,-134,133v-73,0,-134,-57,-134,-133v0,-76,61,-134,134,-134v73,0,134,58,134,134xm278,-127v0,-65,-49,-115,-110,-115v-62,0,-110,50,-110,115v0,65,48,114,110,114v61,0,110,-49,110,-114xm126,-203v47,-2,91,-2,91,42v0,23,-15,42,-40,41v20,15,33,49,47,66r-25,0v-16,-22,-25,-58,-52,-66r0,66r-21,0r0,-149xm147,-134v27,1,49,-1,48,-27v0,-23,-22,-27,-48,-25r0,52","w":316},"\u00ac":{"d":"162,-104r-16,76r-26,0r11,-50r-114,0r5,-26r140,0","w":176},"\u00a9":{"d":"302,-127v0,76,-61,133,-134,133v-73,0,-134,-57,-134,-133v0,-76,61,-134,134,-134v73,0,134,58,134,134xm278,-127v0,-65,-49,-115,-110,-115v-62,0,-110,50,-110,115v0,65,48,114,110,114v61,0,110,-49,110,-114xm134,-126v-6,49,35,73,69,50r10,14v-47,32,-102,-4,-102,-63v0,-60,53,-100,99,-67r-10,14v-35,-24,-72,4,-66,52","w":316},"\u00a6":{"d":"96,-272r-32,147r-23,0r31,-147r24,0xm54,-73r-32,148r-23,0r31,-148r24,0","w":88},"\u00b3":{"d":"62,-180v30,2,45,-2,47,-22v-4,-25,-42,-14,-56,-1r-10,-14v24,-23,92,-33,92,9v0,17,-11,31,-26,38v10,5,17,13,17,25v0,42,-52,63,-102,58r-2,-19v34,7,76,-5,78,-38v-3,-18,-15,-16,-42,-17","w":124},"\u00b2":{"d":"132,-204v0,42,-51,68,-77,91v18,-2,39,-1,59,-1r-9,20r-89,0r3,-14v25,-17,78,-53,85,-91v-3,-28,-39,-14,-55,-3r-9,-13v23,-16,39,-22,56,-22v21,0,36,14,36,33","w":120},"\u00b9":{"d":"109,-235r-25,122r21,0r-4,19r-69,0r5,-19r22,0r19,-93v-12,6,-23,11,-35,16r-3,-15v23,-10,35,-31,69,-30","w":113},"\u00be":{"d":"332,-45r-5,19v-7,1,-19,-4,-18,5r-4,21r-26,7r7,-33r-64,0r3,-16r74,-99r27,0v-13,18,-48,66,-73,96v17,-2,42,8,41,-14r11,-39r22,-6v-3,19,-11,42,-12,59r17,0xm335,-275r-259,330r-24,0r259,-330r24,0xm61,-180v30,1,45,0,47,-22v-3,-25,-42,-13,-56,-1r-9,-14v24,-23,92,-32,92,9v0,17,-12,32,-27,38v10,5,17,13,17,25v0,42,-52,63,-102,58r-2,-19v34,7,76,-5,78,-38v-2,-18,-15,-17,-42,-17","w":354},"\u00bd":{"d":"319,-111v0,41,-50,70,-77,91r60,0r-10,20r-89,0r3,-14v25,-17,78,-53,85,-91v-3,-29,-39,-15,-55,-4r-9,-12v23,-16,39,-23,56,-23v21,0,36,14,36,33xm313,-275r-259,330r-24,0r259,-330r24,0xm110,-235r-26,122r21,0r-3,19r-69,0r4,-19r22,0r20,-93v-12,6,-23,11,-35,16r-4,-15v24,-10,35,-32,70,-30","w":328},"\u00bc":{"d":"316,-45r-4,19r-18,0v0,10,-3,17,-5,26r-25,7r7,-33r-65,0r4,-16r74,-99r27,0v-13,18,-48,66,-73,96v16,-2,41,8,40,-14r11,-39r22,-6v-2,18,-11,46,-11,59r16,0xm320,-275r-260,330r-23,0r259,-330r24,0xm110,-235r-26,122r21,0r-3,19r-69,0r4,-19r22,0r20,-93v-12,6,-23,11,-35,16r-4,-15v24,-10,35,-32,70,-30","w":339},"\u00a0":{"w":81}}});
/*!
 * The following copyright notice may not be removed under any circumstances.
 *
 * Copyright:
 * < info@fontfont.de > Copyright Erik Spiekermann, 1991, 93, 98. Published by
 * FontShop International for  FontFont Release 23, Meta is a trademark of FSI
 * Fonts and Software GmbH.
 */
Cufon.registerFont({"w":201,"face":{"font-family":"Meta","font-weight":700,"font-style":"italic","font-stretch":"normal","units-per-em":"360","panose-1":"2 0 8 3 0 0 0 0 0 0","ascent":"288","descent":"-72","x-height":"4","bbox":"-43 -339 337 81","underline-thickness":"7.2","underline-position":"-51.12","unicode-range":"U+0020-U+2122"},"glyphs":{" ":{"w":81},"!":{"d":"114,-256r-47,176r-37,0r25,-167xm68,-25v0,17,-14,30,-31,30v-16,0,-29,-13,-29,-30v0,-17,13,-30,30,-30v16,0,30,13,30,30","w":109},"\"":{"d":"157,-255r-21,102r-45,0r21,-102r45,0xm74,-255r-21,102r-46,0r21,-102r46,0","w":146},"#":{"d":"199,-150r-37,0r-13,45r29,0r0,33r-37,0r-21,72r-35,0r21,-72r-36,0r-20,72r-35,0r20,-72r-28,0r0,-33r37,0r13,-45r-28,0r0,-33r37,0r20,-72r35,0r-21,72r36,0r20,-72r35,0r-20,72r28,0r0,33xm127,-150r-35,0r-13,45r35,0","w":187},"$":{"d":"223,-233r-31,35v-32,-27,-92,-25,-97,16v-2,18,36,25,52,31v32,12,50,29,50,57v0,50,-41,94,-108,99r-6,29r-31,0r6,-29v-23,-3,-47,-10,-65,-22r26,-39v34,27,117,31,117,-22v0,-44,-98,-26,-98,-87v0,-48,40,-86,92,-92r5,-26r31,0r-5,26v24,3,47,11,62,24","w":209},"%":{"d":"154,-207v0,40,-27,78,-77,78v-31,0,-49,-17,-49,-44v0,-49,33,-81,76,-81v32,0,50,19,50,47xm267,-250r-184,250r-38,0r184,-250r38,0xm284,-75v0,40,-27,78,-77,78v-31,0,-49,-17,-49,-44v0,-49,33,-80,76,-80v32,0,50,18,50,46xm115,-210v0,-13,-5,-17,-16,-17v-22,0,-32,24,-32,56v0,11,6,15,17,15v20,0,31,-26,31,-54xm245,-77v0,-13,-5,-18,-16,-18v-22,0,-32,24,-32,56v0,11,6,15,17,15v20,0,31,-25,31,-53","w":295},"&":{"d":"236,0r-64,0r-12,-16v-18,12,-39,21,-74,21v-102,-1,-97,-104,-17,-131v-48,-46,1,-117,67,-114v83,4,81,87,5,114r-5,3r34,39v6,-10,11,-31,12,-38r40,0v-4,24,-14,52,-27,70xm147,-189v0,-10,-7,-17,-18,-17v-30,0,-40,35,-15,58v21,-8,33,-25,33,-41xm136,-43r-46,-56v-32,13,-44,69,5,69v17,0,31,-5,41,-13","w":252},"\u2019":{"d":"58,-188v0,-14,-21,-19,-17,-37v0,-17,14,-31,31,-31v21,0,36,14,36,39v0,31,-36,62,-66,70r-13,-20v16,-6,29,-13,29,-21","w":93},"(":{"d":"167,-252v-76,40,-96,118,-96,216v0,34,7,53,34,70r-17,27v-111,-42,-58,-251,12,-305v18,-15,38,-28,60,-37","w":120},")":{"d":"-36,30v77,-38,95,-117,95,-215v0,-31,-5,-53,-32,-70r17,-27v64,19,71,101,54,177v-17,78,-58,140,-128,165","w":120},"*":{"d":"184,-186r-47,15r30,41r-30,22r-30,-42r-29,40r-29,-22r30,-39r-48,-17r11,-34r48,17r0,-50r36,0r0,50r48,-16","w":166},"+":{"d":"216,-132r-10,46r-74,0r-16,76r-49,0r16,-76r-74,0r10,-46r74,0r16,-76r49,0r-16,76r74,0","w":222},",":{"d":"18,12v0,-14,-17,-16,-17,-36v0,-18,15,-32,32,-32v21,0,34,14,34,39v0,34,-35,62,-65,70r-14,-21v16,-6,30,-12,30,-20","w":100},"-":{"d":"113,-118r-9,39r-86,0r9,-39r86,0","w":125},".":{"d":"68,-26v0,18,-15,32,-32,32v-18,0,-31,-14,-31,-32v0,-17,14,-32,31,-32v18,0,32,15,32,32","w":100},"\/":{"d":"179,-275r-166,330r-35,0r167,-330r34,0","w":145},"0":{"d":"19,-74v0,-82,39,-170,117,-170v41,0,64,31,64,77v-2,83,-36,172,-117,172v-40,0,-64,-30,-64,-79xm90,-30v47,0,59,-112,59,-148v0,-25,-8,-30,-20,-30v-49,0,-59,108,-59,146v0,26,8,32,20,32"},"1":{"d":"169,-240r-43,201r32,0r-9,39r-117,0r9,-39r38,0r31,-146v-15,8,-35,19,-52,24r-7,-27r85,-52r33,0"},"2":{"d":"200,-190v0,60,-82,117,-127,151v32,-2,74,-1,108,-1r-19,40r-154,0r7,-34v17,-14,53,-43,73,-61v54,-48,57,-70,57,-85v0,-16,-11,-21,-25,-21v-15,0,-32,8,-56,25r-19,-32v31,-23,58,-36,95,-36v37,0,60,22,60,54"},"3":{"d":"134,-244v81,1,86,94,16,116v20,5,33,19,33,39v1,61,-86,112,-176,99r-4,-36v57,14,126,-22,123,-59v6,-23,-30,-25,-62,-24r9,-40v30,4,78,-3,72,-35v-6,-36,-71,-12,-84,2r-19,-31v29,-19,63,-31,92,-31"},"4":{"d":"194,-86r-8,41r-28,-1v0,14,-7,40,-9,55r-47,5r13,-60v-32,2,-73,0,-107,1r6,-33r104,-163r52,0r-77,122v-9,14,-18,26,-24,33r56,0v5,-28,19,-67,27,-97r39,-8r-23,105r26,0"},"5":{"d":"206,-239r-16,41r-71,0r-15,49v45,-6,80,15,80,53v0,64,-72,120,-162,104r-3,-36v50,16,101,-6,109,-47v8,-46,-42,-43,-85,-30r40,-134r123,0"},"6":{"d":"202,-224v-38,10,-83,33,-110,81v41,-25,102,-1,102,52v0,48,-41,96,-103,96v-44,0,-72,-31,-72,-76v0,-85,78,-161,180,-188xm143,-87v0,-36,-40,-30,-66,-15v-10,24,-15,70,20,70v25,0,46,-27,46,-55"},"7":{"d":"219,-239r-15,42v-28,31,-89,115,-119,200r-56,14v50,-109,87,-170,127,-214v-34,3,-74,0,-110,1r20,-43r153,0"},"8":{"d":"208,-194v0,32,-24,57,-59,66v21,6,44,23,44,48v0,55,-54,87,-113,87v-103,0,-90,-106,-20,-130v-59,-43,0,-121,78,-121v43,0,70,20,70,50xm154,-189v0,-13,-8,-19,-28,-19v-34,0,-56,39,-22,54v5,3,7,4,13,7v30,-14,37,-27,37,-42xm137,-68v0,-16,-18,-25,-46,-36v-36,15,-49,76,2,76v26,0,44,-18,44,-40"},"9":{"d":"207,-175v0,94,-79,164,-174,196r-20,-30v41,-10,94,-47,111,-77v-44,22,-93,-10,-93,-53v0,-57,44,-105,107,-105v44,0,69,25,69,69xm145,-131v14,-25,20,-74,-16,-76v-38,-2,-70,86,-16,89v12,0,20,-3,32,-13"},":":{"d":"94,-132v0,17,-15,30,-32,30v-17,0,-31,-13,-31,-30v0,-17,14,-32,31,-32v17,0,32,15,32,32xm71,-25v0,17,-15,31,-32,31v-17,0,-31,-14,-31,-31v0,-17,14,-32,31,-32v17,0,32,15,32,32","w":105},";":{"d":"96,-132v0,17,-14,30,-31,30v-17,0,-32,-13,-32,-30v0,-17,15,-32,32,-32v17,0,31,15,31,32xm25,12v0,-14,-17,-16,-17,-36v0,-18,15,-32,32,-32v21,0,35,14,35,39v0,34,-36,62,-66,70r-13,-21v16,-6,29,-12,29,-20","w":113},"<":{"d":"147,-185r-79,80r43,78r-43,31r-63,-112r111,-112","w":132},"=":{"d":"243,-169r-10,46r-197,0r9,-46r198,0xm226,-95r-9,46r-197,0r9,-46r197,0","w":239},">":{"d":"138,-108r-111,112r-31,-34r79,-80r-43,-79r43,-31","w":132},"?":{"d":"174,-203v0,28,-18,51,-46,67v-32,18,-39,42,-41,60r-41,0v-2,-37,17,-63,48,-82v26,-6,49,-53,6,-55v-20,0,-36,14,-43,19r-15,-32v11,-9,37,-28,74,-28v34,0,58,21,58,51xm91,-25v0,17,-14,30,-31,30v-16,0,-29,-13,-29,-30v0,-17,13,-30,30,-30v16,0,30,13,30,30","w":159},"@":{"d":"308,-99v0,63,-38,106,-82,106v-36,0,-40,-16,-41,-33v-26,38,-101,44,-101,-25v0,-80,80,-144,153,-99v-10,32,-16,65,-23,97v-6,28,-3,32,13,32v22,0,38,-32,38,-78v0,-57,-37,-95,-97,-95v-57,0,-109,58,-109,125v0,87,76,117,151,93r7,30v-99,32,-201,-16,-201,-123v0,-85,66,-158,152,-158v80,0,140,52,140,128xm195,-134v-49,-12,-73,41,-72,84v0,14,4,23,15,23v15,0,38,-16,44,-45","w":322},"A":{"d":"194,0r-53,0r-5,-59r-73,0r-30,59r-55,0r136,-251r54,0xm133,-101r-4,-95v-6,14,-34,73,-45,95r49,0","w":208},"B":{"d":"199,-84v-2,46,-38,84,-101,84r-91,0r53,-250v67,1,156,-14,155,54v0,24,-16,52,-53,63v23,5,37,26,37,49xm89,-150v38,2,68,-2,71,-35v2,-26,-33,-22,-59,-22xm66,-41v44,5,78,-8,78,-44v0,-29,-35,-24,-63,-24","w":211},"C":{"d":"14,-84v0,-106,108,-219,205,-152r-29,33v-10,-9,-24,-13,-38,-13v-58,-1,-80,86,-81,134v-1,56,56,57,90,30r17,33v-60,45,-164,24,-164,-65","w":194},"D":{"d":"60,-250v88,-2,164,-4,160,85v-4,81,-44,177,-152,165r-61,0xm92,-41v58,7,74,-101,74,-125v0,-32,-22,-51,-63,-45r-36,170r25,0","w":222},"E":{"d":"203,-250r-15,41r-85,0r-13,58r71,0r-8,41r-71,0r-14,67r94,0r-9,43r-146,0r53,-250r143,0","w":174},"F":{"d":"196,-250r-14,40r-79,0r-12,58r63,0r-9,41r-63,0r-24,111r-51,0r53,-250r136,0","w":154},"G":{"d":"18,-84v0,-121,125,-221,219,-141r-33,30v-14,-13,-29,-18,-48,-18v-64,0,-80,89,-83,132v-3,46,41,54,75,40r12,-57r-37,0r0,-41r98,0r-26,121v-68,41,-177,24,-177,-66","w":235},"H":{"d":"234,-250r-54,250r-51,0r24,-112r-72,0r-24,112r-50,0r53,-250r51,0r-21,97r72,0r21,-97r51,0","w":224},"I":{"d":"113,-250r-54,250r-52,0r53,-250r53,0","w":103},"J":{"d":"113,-250r-43,201v-8,70,-45,89,-87,109r-17,-27v33,-22,40,-26,51,-76r43,-207r53,0","w":103},"K":{"d":"245,-250r-106,118r61,132r-64,0r-50,-131r-27,131r-52,0r53,-250r52,0r-25,114r95,-114r63,0","w":212},"L":{"d":"157,-42r-18,42r-132,0r53,-250r52,0r-44,208r89,0","w":166},"M":{"d":"289,-250r-31,250r-48,0r26,-175v-25,60,-58,117,-86,175r-43,0r-8,-131v-1,-12,-1,-31,0,-45r-48,176r-51,0r77,-250r63,0r7,165v22,-57,53,-111,78,-165r64,0","w":294},"N":{"d":"234,-250r-53,250r-52,0r-39,-179r-34,179r-49,0r53,-250r56,0v12,52,34,118,39,172v7,-60,21,-116,31,-172r48,0","w":225},"O":{"d":"244,-163v0,82,-46,168,-140,167v-62,0,-85,-38,-85,-90v0,-71,34,-122,66,-145v15,-11,36,-22,74,-22v55,0,85,34,85,90xm112,-35v59,2,73,-91,75,-139v0,-24,-10,-41,-37,-41v-59,1,-77,87,-77,137v0,32,14,43,39,43","w":246},"P":{"d":"126,-250v61,-2,90,13,90,57v0,69,-53,109,-138,101r-19,92r-52,0r53,-250r66,0xm87,-133v48,5,75,-10,75,-50v0,-29,-30,-28,-59,-27"},"Q":{"d":"219,44v-48,14,-77,-29,-114,-40v-61,0,-86,-37,-86,-90v0,-71,34,-121,66,-144v15,-11,36,-23,74,-23v135,2,88,211,5,244v16,12,45,29,72,21xm112,-35v59,1,74,-91,76,-139v0,-24,-11,-41,-38,-41v-59,1,-77,87,-77,137v0,32,14,43,39,43","w":246},"R":{"d":"213,-195v0,49,-34,81,-72,87v21,15,45,103,49,108r-60,0v-13,-32,-28,-111,-50,-104r-22,104r-51,0r53,-250v66,1,153,-14,153,55xm88,-142v45,4,69,-11,71,-43v1,-26,-29,-26,-56,-25","w":203},"S":{"d":"226,-233r-30,35v-25,-25,-94,-26,-97,14v-2,20,35,28,52,35v32,12,49,31,49,59v0,54,-46,95,-121,95v-35,0,-62,-9,-83,-22r27,-39v34,27,115,31,117,-22v1,-22,-34,-29,-53,-36v-28,-10,-46,-27,-46,-56v0,-80,128,-115,185,-63","w":216},"T":{"d":"219,-250r-18,42r-59,0r-44,208r-52,0r44,-208r-61,0r9,-42r181,0","w":176},"U":{"d":"239,-250r-36,168v-7,32,-13,49,-32,64v-10,7,-28,23,-75,23v-61,0,-85,-29,-74,-81r37,-174r52,0r-38,187v4,41,70,24,76,-6r39,-181r51,0","w":228},"V":{"d":"249,-250r-141,252r-46,0r-31,-252r54,0r15,177v28,-61,63,-118,94,-177r55,0","w":210},"W":{"d":"330,-250r-114,251r-55,0r0,-101v0,-40,3,-73,4,-80v-8,30,-53,140,-72,181r-56,0r-6,-251r52,0r1,98v0,47,-4,84,-4,84v12,-41,53,-135,74,-182r54,0r-4,179v12,-41,52,-131,72,-179r54,0","w":292},"X":{"d":"226,-250r-90,118r49,132r-59,0r-27,-86r-62,86r-64,0r108,-135r-44,-115r58,0r22,70r49,-70r60,0","w":190},"Y":{"d":"238,-250r-112,147r-22,103r-52,0r22,-103r-47,-147r59,0r23,100r67,-100r62,0","w":195},"Z":{"d":"213,-250r-7,36r-125,157v-7,9,-15,16,-15,16v27,-2,74,-1,105,-1r-17,42r-160,0r8,-35r142,-175v-21,3,-71,2,-99,2r16,-42r152,0","w":190},"[":{"d":"131,-264r-7,33r-33,0r-54,255r33,0r-7,32r-76,0r68,-320r76,0","w":109},"\\":{"d":"129,8r-44,10r-48,-281r44,-9","w":149},"]":{"d":"123,-264r-68,320r-76,0r7,-32r32,0r54,-255r-32,0r7,-33r76,0","w":109},"^":{"d":"200,-123r-51,0r-22,-86r-58,86r-51,0r93,-132r52,0","w":211},"_":{"d":"150,27r-5,21r-180,0r5,-21r180,0","w":166},"\u2018":{"d":"86,-217v0,14,22,19,18,37v0,17,-15,31,-32,31v-21,0,-35,-14,-35,-39v0,-31,35,-62,65,-70r14,20v-16,6,-30,13,-30,21","w":93},"a":{"d":"8,-54v4,-76,39,-134,112,-134v22,0,46,4,61,13v-11,34,-18,78,-27,115v-3,16,-2,27,7,36r-40,30v-9,-6,-13,-16,-14,-23v-32,37,-103,28,-99,-37xm126,-148v-50,-17,-70,53,-69,92v0,17,5,24,15,24v47,0,41,-75,54,-116","w":186},"b":{"d":"190,-125v0,63,-39,129,-106,130v-30,0,-59,-8,-74,-18r42,-189v5,-24,6,-38,3,-51r50,-16v6,30,-7,76,-15,103v29,-38,100,-30,100,41xm90,-31v34,1,48,-67,48,-95v0,-16,-5,-24,-15,-24v-15,0,-29,12,-39,29r-18,82v4,4,12,8,24,8","w":199},"c":{"d":"12,-59v0,-88,84,-171,156,-109r-28,30v-46,-42,-78,32,-76,79v1,43,40,29,62,9r17,30v-40,39,-131,35,-131,-39","w":156},"d":{"d":"12,-60v0,-67,53,-149,131,-122r17,-84r46,7v-13,75,-45,187,-48,259r-41,0v-1,-3,-2,-12,-2,-17v-34,39,-103,26,-103,-43xm133,-141v-44,-29,-71,43,-71,81v0,45,44,23,53,2","w":194},"e":{"d":"12,-63v1,-60,40,-125,105,-125v36,0,63,14,63,50v0,41,-56,71,-116,61v-4,23,2,46,30,46v17,0,34,-7,51,-19r12,30v-51,40,-148,37,-145,-43xm131,-134v0,-11,-5,-19,-19,-19v-18,0,-33,11,-40,43v21,6,60,-2,59,-24","w":182},"f":{"d":"49,-184v-3,-68,63,-103,117,-71r-21,29v-31,-18,-49,13,-50,42r47,0r-19,33r-33,0v-20,81,-22,187,-76,232r-29,-27v40,-45,40,-137,58,-205r-18,0r7,-33r17,0","w":113},"g":{"d":"12,-59v4,-61,38,-131,107,-129v31,0,52,3,73,12v-14,50,-30,142,-40,190v-15,73,-107,78,-163,48r17,-32v26,19,95,19,98,-19v1,-6,3,-16,5,-22v-37,33,-101,15,-97,-48xm136,-146v-49,-21,-73,45,-73,86v0,45,48,26,53,3","w":197},"h":{"d":"148,-189v39,0,48,24,40,60r-28,129r-47,0r26,-124v4,-18,1,-25,-13,-25v-13,0,-33,14,-45,29r-26,120r-48,0r43,-202v6,-28,7,-41,4,-51r49,-16v6,28,-7,80,-15,106v14,-15,37,-26,60,-26","w":203},"i":{"d":"111,-235v0,17,-13,30,-30,30v-16,0,-29,-13,-29,-30v0,-17,13,-30,30,-30v16,0,29,13,29,30xm95,-189r-40,189r-48,0r39,-181","w":97},"j":{"d":"108,-235v0,17,-13,30,-30,30v-16,0,-30,-13,-30,-30v0,-17,13,-30,30,-30v16,0,30,13,30,30xm92,-189r-39,184v-16,61,-27,62,-69,84r-15,-28v20,-12,30,-25,36,-55r37,-177","w":92},"k":{"d":"201,-184r-75,80r49,104r-57,0r-39,-104r62,-80r60,0xm104,-269v1,79,-36,191,-49,269r-48,0r43,-202v5,-26,7,-41,4,-51","w":181},"l":{"d":"103,-269v2,75,-31,160,-39,230v-1,9,7,12,14,9r3,29v-28,11,-71,3,-68,-28v7,-71,40,-153,38,-224","w":97},"m":{"d":"235,-188v30,0,41,29,34,62r-27,126r-47,0r29,-138v0,-8,-3,-10,-12,-10v-13,0,-27,11,-38,28r-26,120r-46,0r28,-138v0,-8,-3,-10,-11,-10v-13,0,-26,10,-39,28r-26,120r-47,0v8,-55,35,-113,26,-173r45,-17v3,6,5,19,4,29v18,-18,38,-27,59,-27v19,0,32,8,34,27v20,-20,41,-27,60,-27","w":284},"n":{"d":"145,-188v34,-1,41,30,34,62r-26,126r-48,0r28,-136v0,-9,-3,-12,-12,-12v-12,0,-26,7,-41,28r-25,120r-48,0v8,-55,34,-112,26,-173r45,-17v3,6,6,21,5,29v15,-17,35,-27,62,-27","w":194},"o":{"d":"183,-125v0,65,-35,129,-108,129v-42,0,-66,-23,-66,-65v0,-69,44,-127,107,-127v41,0,67,23,67,63xm131,-125v0,-21,-9,-27,-23,-27v-32,0,-48,67,-48,95v0,18,9,26,23,26v31,0,48,-58,48,-94","w":192},"p":{"d":"191,-127v0,72,-54,158,-137,124r-14,70r-49,12r44,-206v4,-21,3,-35,-1,-46r45,-17v3,5,6,21,5,29v31,-39,107,-37,107,34xm88,-32v43,0,48,-63,51,-94v-5,-40,-40,-21,-58,7r-17,79v3,4,14,8,24,8","w":199},"q":{"d":"12,-56v4,-69,37,-134,114,-132v27,0,53,4,67,13v-21,75,-36,164,-54,243r-49,12r22,-95v-36,34,-104,27,-100,-41xm138,-148v-53,-19,-79,52,-75,88v5,46,40,30,56,1","w":197},"r":{"d":"151,-185r-21,43v-22,-9,-28,-3,-49,21r-26,121r-48,0v8,-54,34,-114,27,-173r44,-17v3,6,6,19,5,29v21,-21,40,-35,68,-24","w":129},"s":{"d":"167,-173r-19,33v-16,-9,-31,-13,-45,-13v-30,-2,-37,28,-8,37v26,8,58,19,58,53v0,37,-29,69,-89,69v-27,0,-51,-9,-72,-21r20,-35v20,16,82,33,87,-4v1,-15,-30,-20,-44,-26v-19,-7,-33,-21,-33,-46v0,-32,24,-63,84,-63v24,0,46,7,61,16","w":170},"t":{"d":"136,-184r-17,33r-32,0v-6,37,-18,69,-21,109v-1,18,22,14,34,9r0,29v-41,18,-94,8,-82,-47r21,-100r-18,0r7,-33r18,0v4,-18,6,-30,11,-44r51,-12v-5,17,-11,37,-15,56r43,0","w":110},"u":{"d":"189,-189r-30,141v-3,12,-1,29,4,38r-42,16v-4,-6,-7,-15,-8,-24v-22,30,-102,34,-99,-15v3,-49,20,-100,29,-147r50,-9r-26,118v-3,18,-7,36,8,39v15,0,33,-15,40,-27r25,-120","w":193},"v":{"d":"191,-184r-107,184r-40,0r-28,-181r50,-7r11,128v14,-38,43,-87,62,-124r52,0","w":163},"w":{"d":"270,-184r-91,184r-45,0r-3,-126v-14,40,-39,86,-56,126r-45,0r-12,-181r48,-5r-2,128v4,-15,44,-100,58,-126r45,0r2,126v10,-29,36,-92,51,-126r50,0","w":248},"x":{"d":"187,-184r-76,89r46,95r-57,0v-9,-25,-19,-50,-21,-62v-6,10,-34,47,-47,62r-63,0r90,-99r-35,-77r50,-13v6,14,16,38,20,55v8,-14,27,-40,35,-50r58,0","w":164},"y":{"d":"205,-184r-107,187v-32,55,-42,66,-96,78r-10,-33v34,-8,49,-19,65,-48r-14,0v-3,-62,-14,-122,-21,-181r50,-6r10,146v12,-31,52,-107,71,-143r52,0","w":181},"z":{"d":"161,-184r-4,33r-106,118r81,0r-15,33r-136,0r3,-30r113,-120r-77,0r5,-34r136,0","w":149},"{":{"d":"171,-264r-9,42v-25,-3,-48,7,-46,23r-12,58v-6,34,-32,34,-45,38v15,1,35,4,28,37r-12,58v-8,16,12,27,36,23r-8,41v-47,2,-84,2,-73,-52r12,-62v5,-22,-24,-25,-33,-25r9,-41v9,0,40,-3,44,-25v9,-48,20,-121,71,-115r38,0","w":139},"|":{"d":"125,-272r-74,347r-45,0r73,-347r46,0","w":109},"}":{"d":"139,-124r-9,41v-10,0,-40,3,-44,25v-9,47,-20,120,-71,114r-38,0r9,-41v25,3,48,-7,46,-23r12,-58v6,-34,31,-34,44,-38v-15,-1,-35,-4,-28,-37r13,-58v9,-17,-14,-27,-37,-23r9,-42v48,-2,85,-2,73,53r-13,62v-5,22,24,25,34,25","w":139},"~":{"d":"188,-104v-11,15,-30,30,-54,30v-28,0,-47,-25,-69,-25v-14,0,-27,13,-37,24r-10,-37v11,-15,30,-32,54,-32v24,0,49,24,71,24v14,0,25,-10,36,-21"},"\u00a1":{"d":"100,-150v0,17,-13,30,-30,30v-16,0,-29,-13,-29,-30v0,-17,13,-30,30,-30v16,0,29,13,29,30xm77,-95r-24,167r-60,9r48,-176r36,0","w":109},"\u00a2":{"d":"139,-138v-46,-42,-77,31,-75,79v2,43,40,29,62,9r16,30v-15,12,-31,20,-50,23r-8,37r-34,0r8,-37v-79,-14,-42,-142,0,-171v13,-9,25,-17,41,-20r7,-34r34,0r-7,34v13,3,24,9,34,20","w":156},"\u00a3":{"d":"246,-233r-40,35v-38,-36,-89,4,-87,49r56,0r-8,37r-56,0r-15,71r91,0r-8,41r-180,0r9,-41r34,0r15,-71r-34,0r8,-37r34,0v9,-62,40,-110,113,-110v27,0,52,8,68,26","w":209},"\u00a5":{"d":"233,-250r-76,101r37,0r-8,37r-57,0v-7,6,-9,16,-11,27r62,0r-8,37r-62,0r-10,48r-52,0r10,-48r-61,0r8,-37r61,0v2,-9,5,-19,0,-27r-56,0r8,-37r37,0r-32,-101r59,0r23,100r67,-100r61,0","w":191},"\u0192":{"d":"64,-184v4,-62,58,-104,113,-71r-19,29v-31,-19,-48,14,-51,42r42,0r-18,34r-31,0v-29,80,-31,206,-109,229r-16,-32v25,-13,34,-25,41,-51r40,-146r-17,0r7,-34r18,0","w":142},"\u00a7":{"d":"207,-223r-48,26v-3,-28,-57,-28,-57,1v0,28,92,34,92,85v0,27,-18,48,-41,58v39,54,-27,107,-92,107v-36,0,-64,-10,-73,-45r49,-22v3,32,68,33,68,2v0,-32,-90,-29,-90,-86v0,-23,19,-48,45,-62v-44,-43,17,-102,76,-102v31,0,61,8,71,38xm123,-69v23,-11,23,-37,0,-49r-36,-19v-11,5,-19,16,-19,27v0,25,37,28,55,41","w":194},"\u00a4":{"d":"246,-242r-20,42v-27,-29,-86,-16,-96,24r70,0r-8,35r-76,0v-3,9,-3,19,-5,28r75,0r-7,35r-72,0v-1,48,56,53,92,30r4,39v-60,31,-156,6,-150,-69r-42,0r7,-35r37,0v2,-9,4,-19,7,-28r-38,0r8,-35r44,0v19,-68,107,-99,170,-66","w":226},"'":{"d":"103,-255r-22,102r-45,0r21,-102r46,0","w":91},"\u201c":{"d":"168,-217v0,14,21,19,17,37v0,17,-14,31,-31,31v-21,0,-36,-14,-36,-39v0,-31,36,-62,66,-70r13,20v-16,6,-29,13,-29,21xm86,-217v0,14,22,19,18,37v0,17,-15,31,-32,31v-21,0,-35,-14,-35,-39v0,-31,35,-62,65,-70r14,20v-16,6,-30,13,-30,21","w":174},"\u00ab":{"d":"206,-151r-56,63r28,61r-37,22r-39,-85r75,-84xm119,-151r-56,63r28,61r-37,22r-39,-85r75,-84","w":202},"\u2013":{"d":"195,-117r-8,37r-175,0r8,-37r175,0","w":200},"\u00b7":{"d":"89,-98v0,17,-14,31,-32,31v-18,0,-32,-14,-32,-32v0,-18,15,-32,33,-32v18,0,31,15,31,33","w":108},"\u00b6":{"d":"219,-255r-63,300r-33,0r58,-274r-38,0r-58,274r-33,0r36,-167v-41,0,-65,-21,-65,-52v0,-49,37,-81,99,-81r97,0","w":208},"\u2022":{"d":"159,-127v0,35,-29,63,-64,63v-35,0,-63,-28,-63,-63v0,-35,28,-64,63,-64v35,0,64,29,64,64","w":173},"\u201d":{"d":"140,-188v0,-14,-21,-19,-17,-37v0,-17,14,-31,31,-31v21,0,35,14,35,39v0,31,-35,62,-65,70r-13,-20v16,-6,29,-13,29,-21xm59,-188v0,-14,-22,-19,-18,-37v0,-17,15,-31,32,-31v21,0,35,14,35,39v0,31,-35,62,-65,70r-14,-20v16,-6,30,-13,30,-21","w":174},"\u00bb":{"d":"189,-90r-75,85r-29,-23r56,-63r-28,-62r37,-21xm102,-90r-75,85r-29,-23r56,-63r-28,-62r37,-21","w":203},"\u2026":{"d":"252,-26v0,18,-15,32,-32,32v-18,0,-32,-14,-32,-32v0,-17,15,-32,32,-32v18,0,32,15,32,32xm162,-26v0,18,-15,32,-32,32v-18,0,-32,-14,-32,-32v0,-17,15,-32,32,-32v18,0,32,15,32,32xm72,-26v0,18,-15,32,-32,32v-18,0,-32,-14,-32,-32v0,-17,15,-32,32,-32v18,0,32,15,32,32","w":291},"\u00bf":{"d":"130,-150v0,17,-13,30,-30,30v-16,0,-30,-13,-30,-30v0,-17,13,-30,30,-30v16,0,30,13,30,30xm121,50v-11,9,-41,29,-77,29v-32,0,-57,-19,-57,-49v0,-33,19,-53,45,-67v32,-18,39,-40,41,-58r41,0v1,38,-15,60,-46,79v-24,15,-31,20,-31,35v0,30,56,17,67,2","w":159},"`":{"d":"130,-226r-17,25r-77,-36r23,-38","w":105},"\u00b4":{"d":"140,-237r-86,38r-14,-27r83,-48","w":118},"\u00af":{"d":"153,-268r-6,28r-113,0r6,-28r113,0","w":114},"\u00a8":{"d":"172,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm96,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27","w":153},"\u00b8":{"d":"48,33v0,32,-50,51,-76,30r15,-22v9,12,46,-2,21,-9v-8,1,-12,3,-13,-5r15,-31r26,2r-8,14v15,1,20,10,20,21","w":77},"\u2014":{"d":"276,-117r-7,37r-257,0r8,-37r256,0","w":281},"\u00c6":{"d":"309,-250r-16,41r-83,0r-12,58r71,0r-8,41r-71,0r-14,67r96,0r-10,43r-147,0r13,-59r-67,0r-46,59r-58,0r202,-250r150,0xm155,-184r-61,83r43,0","w":280},"\u00aa":{"d":"41,-180v0,-71,62,-121,129,-86v-11,26,-14,56,-21,85v-2,9,-1,14,7,22r-32,24v-7,-4,-9,-9,-11,-14v-25,24,-72,15,-72,-31xm154,-114r-6,28r-132,0r6,-28r132,0xm124,-244v-32,-9,-42,36,-42,63v0,9,1,13,7,13v30,0,26,-49,35,-76","w":153},"\u0141":{"d":"157,-42r-18,42r-132,0r23,-106r-22,7r7,-33r22,-7r23,-111r52,0r-20,94r57,-17r-7,33r-57,17r-17,81r89,0","w":166},"\u00d8":{"d":"32,-9r-35,42r-20,-18r35,-43v-38,-68,9,-181,51,-203v18,-19,93,-32,124,-10r31,-37r21,17r-32,39v55,118,-50,271,-175,213xm52,-76r105,-128v-68,-45,-109,68,-105,128xm166,-172r-104,127v18,16,52,14,69,-8v21,-26,35,-84,35,-119","w":233},"\u0152":{"d":"19,-84v0,-89,54,-166,163,-166r143,0r-15,41r-86,0r-12,58r71,0r-8,41r-72,0r-14,67r97,0r-10,43r-146,0v-81,5,-111,-20,-111,-84xm149,-207v-55,-1,-65,78,-71,123v-5,36,34,53,63,41r35,-161v0,0,-14,-3,-27,-3","w":296},"\u00ba":{"d":"170,-229v0,47,-25,93,-78,93v-31,0,-49,-19,-49,-50v0,-50,31,-90,77,-90v31,0,50,17,50,47xm152,-114r-6,28r-131,0r6,-28r131,0xm128,-229v0,-13,-5,-17,-13,-17v-22,0,-30,46,-30,65v0,10,5,14,13,14v21,0,30,-38,30,-62","w":153},"\u00e6":{"d":"276,-136v-1,50,-59,66,-115,60v-6,22,2,45,29,45v17,0,34,-7,51,-19r12,30v-39,30,-101,37,-131,1v-28,39,-114,34,-114,-20v0,-47,45,-78,114,-75v4,-15,11,-35,-14,-35v-15,0,-35,7,-58,20r-14,-33v32,-20,99,-40,129,-10v35,-27,113,-23,111,36xm228,-134v0,-11,-6,-19,-20,-19v-18,0,-33,12,-39,44v23,4,60,-3,59,-25xm103,-41v2,-6,18,-45,7,-40v-36,0,-49,12,-49,36v0,24,33,19,42,4","w":278},"\u0131":{"d":"95,-189r-40,189r-48,0r39,-181","w":97},"\u0142":{"d":"107,-159r-7,33r-20,6r-16,81v-1,9,7,12,14,9r3,29v-28,11,-71,3,-68,-28v2,-20,10,-54,14,-74r-16,5r7,-33r16,-5v5,-33,23,-86,17,-117r52,-16v4,29,-10,87,-17,116","w":97},"\u00f8":{"d":"202,-201r-30,37v42,78,-31,201,-131,160v-14,18,-29,35,-29,35r-18,-15r29,-35v-45,-80,36,-205,131,-160r30,-36xm127,-145v-40,-29,-62,43,-65,80xm131,-114r-63,77v38,25,60,-36,63,-77","w":193},"\u0153":{"d":"287,-136v0,50,-61,68,-115,59v-6,22,1,46,29,46v17,0,34,-7,51,-19r13,30v-39,29,-99,37,-130,3v-39,37,-126,25,-126,-45v0,-89,91,-163,158,-106v36,-31,121,-32,120,32xm239,-134v0,-11,-6,-19,-20,-19v-18,0,-32,11,-39,43v21,6,60,-2,59,-24xm131,-125v0,-21,-9,-27,-23,-27v-32,0,-48,67,-48,95v0,18,9,26,23,26v31,0,48,-58,48,-94","w":289},"\u00df":{"d":"208,-210v0,51,-55,56,-55,69v0,14,48,18,48,61v0,56,-64,99,-125,80r18,-33v29,8,55,-14,54,-43v0,-32,-40,-26,-40,-58v0,-39,45,-29,45,-71v0,-12,-6,-19,-18,-19v-19,0,-27,9,-37,47v-23,89,-26,206,-85,258r-29,-27v39,-46,41,-138,60,-205r-28,0r7,-33r28,0v8,-51,35,-77,91,-77v42,0,66,22,66,51","w":216},"\u0178":{"d":"198,-288v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm122,-288v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm238,-250r-112,147r-22,103r-52,0r22,-103r-47,-147r59,0r23,100r67,-100r62,0","w":195},"\u2122":{"d":"337,-255r-18,156r-37,0r12,-86v-17,27,-29,58,-44,86r-32,0r-7,-86r-23,86r-39,0r48,-156r45,0r6,87r43,-87r46,0xm161,-255r-13,31r-37,0r-25,125r-40,0r26,-125r-38,0r6,-31r121,0","w":342},"\u017e":{"d":"168,-248r-75,49r-56,-49r20,-26r44,27r55,-27xm161,-184r-4,33r-106,118r81,0r-15,33r-136,0r3,-30r113,-120r-77,0r5,-34r136,0","w":149},"\u017d":{"d":"212,-313r-75,49r-56,-49r20,-26r44,27r55,-27xm213,-250r-7,36r-125,157v-7,9,-15,16,-15,16v27,-2,74,-1,105,-1r-17,42r-160,0r8,-35r142,-175v-21,3,-71,2,-99,2r16,-42r152,0","w":190},"\u0161":{"d":"178,-248r-75,49r-56,-49r20,-26r44,27r55,-27xm167,-173r-19,33v-16,-9,-31,-13,-45,-13v-30,-2,-37,28,-8,37v26,8,58,19,58,53v0,37,-29,69,-89,69v-27,0,-51,-9,-72,-21r20,-35v20,16,82,33,87,-4v1,-15,-30,-20,-44,-26v-19,-7,-33,-21,-33,-46v0,-32,24,-63,84,-63v24,0,46,7,61,16","w":170},"\u0160":{"d":"220,-313r-75,49r-56,-49r20,-26r44,27r55,-27xm226,-233r-30,35v-25,-25,-94,-26,-97,14v-2,20,35,28,52,35v32,12,49,31,49,59v0,54,-46,95,-121,95v-35,0,-62,-9,-83,-22r27,-39v34,27,115,31,117,-22v1,-22,-34,-29,-53,-36v-28,-10,-46,-27,-46,-56v0,-80,128,-115,185,-63","w":216},"\u00ff":{"d":"182,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm106,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm205,-184r-107,187v-32,55,-42,66,-96,78r-10,-33v34,-8,49,-19,65,-48r-14,0v-3,-62,-14,-122,-21,-181r50,-6r10,146v12,-31,52,-107,71,-143r52,0","w":181},"\u00fe":{"d":"189,-125v0,71,-50,146,-135,127r-14,65r-49,12r60,-281v5,-24,6,-38,3,-51r50,-16v6,30,-7,76,-15,103v29,-38,100,-30,100,41xm89,-31v34,1,48,-67,48,-95v0,-16,-5,-24,-15,-24v-15,0,-30,12,-40,29r-18,82v4,4,13,8,25,8","w":196},"\u00fd":{"d":"169,-237r-86,38r-14,-27r83,-48xm205,-184r-107,187v-32,55,-42,66,-96,78r-10,-33v34,-8,49,-19,65,-48r-14,0v-3,-62,-14,-122,-21,-181r50,-6r10,146v12,-31,52,-107,71,-143r52,0","w":181},"\u00fc":{"d":"188,-229v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm112,-229v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm189,-189r-30,141v-3,12,-1,29,4,38r-42,16v-4,-6,-7,-15,-8,-24v-22,30,-102,34,-99,-15v3,-49,20,-100,29,-147r50,-9r-26,118v-3,18,-7,36,8,39v15,0,33,-15,40,-27r25,-120","w":193},"\u00fb":{"d":"186,-225r-19,26r-45,-28r-54,28r-13,-26r75,-49xm189,-189r-30,141v-3,12,-1,29,4,38r-42,16v-4,-6,-7,-15,-8,-24v-22,30,-102,34,-99,-15v3,-49,20,-100,29,-147r50,-9r-26,118v-3,18,-7,36,8,39v15,0,33,-15,40,-27r25,-120","w":193},"\u00fa":{"d":"181,-237r-86,38r-14,-27r83,-48xm189,-189r-30,141v-3,12,-1,29,4,38r-42,16v-4,-6,-7,-15,-8,-24v-22,30,-102,34,-99,-15v3,-49,20,-100,29,-147r50,-9r-26,118v-3,18,-7,36,8,39v15,0,33,-15,40,-27r25,-120","w":193},"\u00f9":{"d":"162,-226r-17,25r-78,-36r24,-38xm189,-189r-30,141v-3,12,-1,29,4,38r-42,16v-4,-6,-7,-15,-8,-24v-22,30,-102,34,-99,-15v3,-49,20,-100,29,-147r50,-9r-26,118v-3,18,-7,36,8,39v15,0,33,-15,40,-27r25,-120","w":193},"\u00f7":{"d":"152,-168v0,17,-14,31,-31,31v-17,0,-31,-14,-31,-31v0,-17,14,-31,31,-31v17,0,31,14,31,31xm201,-115r-8,38r-182,0r8,-38r182,0xm121,-24v0,17,-14,30,-31,30v-17,0,-31,-13,-31,-30v0,-18,14,-33,31,-33v17,0,31,15,31,33","w":206},"\u00f6":{"d":"186,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm110,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm183,-125v0,65,-35,129,-108,129v-42,0,-66,-23,-66,-65v0,-69,44,-127,107,-127v41,0,67,23,67,63xm131,-125v0,-21,-9,-27,-23,-27v-32,0,-48,67,-48,95v0,18,9,26,23,26v31,0,48,-58,48,-94","w":192},"\u00f5":{"d":"184,-232v-15,15,-28,24,-49,24v-26,0,-51,-27,-71,-1r-12,-27v15,-15,28,-24,47,-24v26,0,52,27,73,2xm183,-125v0,65,-35,129,-108,129v-42,0,-66,-23,-66,-65v0,-69,44,-127,107,-127v41,0,67,23,67,63xm131,-125v0,-21,-9,-27,-23,-27v-32,0,-48,67,-48,95v0,18,9,26,23,26v31,0,48,-58,48,-94","w":192},"\u00f4":{"d":"183,-225r-19,26r-44,-28r-55,28r-13,-26r75,-49xm183,-125v0,65,-35,129,-108,129v-42,0,-66,-23,-66,-65v0,-69,44,-127,107,-127v41,0,67,23,67,63xm131,-125v0,-21,-9,-27,-23,-27v-32,0,-48,67,-48,95v0,18,9,26,23,26v31,0,48,-58,48,-94","w":192},"\u00f3":{"d":"175,-237r-86,38r-14,-27r83,-48xm183,-125v0,65,-35,129,-108,129v-42,0,-66,-23,-66,-65v0,-69,44,-127,107,-127v41,0,67,23,67,63xm131,-125v0,-21,-9,-27,-23,-27v-32,0,-48,67,-48,95v0,18,9,26,23,26v31,0,48,-58,48,-94","w":192},"\u00f2":{"d":"161,-226r-17,25r-78,-36r24,-38xm183,-125v0,65,-35,129,-108,129v-42,0,-66,-23,-66,-65v0,-69,44,-127,107,-127v41,0,67,23,67,63xm131,-125v0,-21,-9,-27,-23,-27v-32,0,-48,67,-48,95v0,18,9,26,23,26v31,0,48,-58,48,-94","w":192},"\u00f1":{"d":"186,-232v-15,15,-28,24,-49,24v-26,0,-51,-27,-71,-1r-12,-27v15,-15,28,-24,47,-24v26,0,53,27,74,2xm145,-188v34,-1,41,30,34,62r-26,126r-48,0r28,-136v0,-9,-3,-12,-12,-12v-12,0,-26,7,-41,28r-25,120r-48,0v8,-55,34,-112,26,-173r45,-17v3,6,6,21,5,29v15,-17,35,-27,62,-27","w":194},"\u00f0":{"d":"126,-218v75,59,56,221,-55,222v-39,0,-68,-19,-68,-64v0,-59,51,-103,114,-89v-5,-13,-14,-27,-27,-36r-19,17r-26,-13r21,-19v-13,-6,-29,-12,-48,-14r36,-34v15,2,32,7,48,15r14,-13r27,13xm121,-109v-6,-4,-11,-5,-28,-5v-29,0,-41,28,-41,51v0,17,9,28,26,28v37,0,43,-52,43,-74","w":189},"\u00ef":{"d":"142,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm66,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm95,-189r-40,189r-48,0r39,-181","w":97},"\u00ee":{"d":"142,-225r-20,26r-44,-28r-54,28r-13,-26r75,-49xm95,-189r-40,189r-48,0r39,-181","w":97},"\u00ed":{"d":"138,-237r-87,38r-14,-27r83,-48xm95,-189r-40,189r-48,0r39,-181","w":97},"\u00ec":{"d":"116,-226r-17,25r-77,-36r23,-38xm95,-189r-40,189r-48,0r39,-181","w":97},"\u00eb":{"d":"188,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm112,-229v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm12,-63v1,-60,40,-125,105,-125v36,0,63,14,63,50v0,41,-56,71,-116,61v-4,23,2,46,30,46v17,0,34,-7,51,-19r12,30v-51,40,-148,37,-145,-43xm131,-134v0,-11,-5,-19,-19,-19v-18,0,-33,11,-40,43v21,6,60,-2,59,-24","w":182},"\u00ea":{"d":"184,-225r-20,26r-44,-28r-54,28r-13,-26r75,-49xm12,-63v1,-60,40,-125,105,-125v36,0,63,14,63,50v0,41,-56,71,-116,61v-4,23,2,46,30,46v17,0,34,-7,51,-19r12,30v-51,40,-148,37,-145,-43xm131,-134v0,-11,-5,-19,-19,-19v-18,0,-33,11,-40,43v21,6,60,-2,59,-24","w":182},"\u00e9":{"d":"176,-237r-86,38r-14,-27r83,-48xm12,-63v1,-60,40,-125,105,-125v36,0,63,14,63,50v0,41,-56,71,-116,61v-4,23,2,46,30,46v17,0,34,-7,51,-19r12,30v-51,40,-148,37,-145,-43xm131,-134v0,-11,-5,-19,-19,-19v-18,0,-33,11,-40,43v21,6,60,-2,59,-24","w":182},"\u00e8":{"d":"159,-226r-16,25r-78,-36r24,-38xm12,-63v1,-60,40,-125,105,-125v36,0,63,14,63,50v0,41,-56,71,-116,61v-4,23,2,46,30,46v17,0,34,-7,51,-19r12,30v-51,40,-148,37,-145,-43xm131,-134v0,-11,-5,-19,-19,-19v-18,0,-33,11,-40,43v21,6,60,-2,59,-24","w":182},"\u00e7":{"d":"12,-59v0,-88,84,-171,156,-109r-28,30v-46,-42,-78,32,-76,79v1,43,40,29,62,9r17,30v-19,15,-39,24,-65,25r-4,7v15,1,20,10,20,21v0,32,-50,51,-76,30r15,-22v9,12,46,-2,21,-9v-8,1,-12,3,-13,-5r12,-25v-27,-7,-41,-29,-41,-61","w":156},"\u00e5":{"d":"163,-237v0,21,-17,38,-38,38v-21,0,-38,-17,-38,-38v0,-21,18,-38,39,-38v21,0,37,17,37,38xm8,-54v4,-76,39,-134,112,-134v22,0,46,4,61,13v-11,34,-18,78,-27,115v-3,16,-2,27,7,36r-40,30v-9,-6,-13,-16,-14,-23v-32,37,-103,28,-99,-37xm140,-237v0,-9,-6,-16,-14,-16v-9,0,-16,7,-16,16v0,9,7,15,15,15v9,0,15,-6,15,-15xm126,-148v-50,-17,-70,53,-69,92v0,17,5,24,15,24v47,0,41,-75,54,-116","w":186},"\u00e4":{"d":"190,-229v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm114,-229v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-27,28,-27v15,0,27,12,27,27xm8,-54v4,-76,39,-134,112,-134v22,0,46,4,61,13v-11,34,-18,78,-27,115v-3,16,-2,27,7,36r-40,30v-9,-6,-13,-16,-14,-23v-32,37,-103,28,-99,-37xm126,-148v-50,-17,-70,53,-69,92v0,17,5,24,15,24v47,0,41,-75,54,-116","w":186},"\u00e3":{"d":"187,-232v-15,15,-28,24,-49,24v-26,0,-51,-27,-71,-1r-12,-27v15,-15,28,-24,47,-24v26,0,52,27,73,2xm8,-54v4,-76,39,-134,112,-134v22,0,46,4,61,13v-11,34,-18,78,-27,115v-3,16,-2,27,7,36r-40,30v-9,-6,-13,-16,-14,-23v-32,37,-103,28,-99,-37xm126,-148v-50,-17,-70,53,-69,92v0,17,5,24,15,24v47,0,41,-75,54,-116","w":186},"\u00e2":{"d":"185,-225r-19,26r-45,-28r-54,28r-13,-26r75,-49xm8,-54v4,-76,39,-134,112,-134v22,0,46,4,61,13v-11,34,-18,78,-27,115v-3,16,-2,27,7,36r-40,30v-9,-6,-13,-16,-14,-23v-32,37,-103,28,-99,-37xm126,-148v-50,-17,-70,53,-69,92v0,17,5,24,15,24v47,0,41,-75,54,-116","w":186},"\u00e1":{"d":"181,-237r-86,38r-15,-27r83,-48xm8,-54v4,-76,39,-134,112,-134v22,0,46,4,61,13v-11,34,-18,78,-27,115v-3,16,-2,27,7,36r-40,30v-9,-6,-13,-16,-14,-23v-32,37,-103,28,-99,-37xm126,-148v-50,-17,-70,53,-69,92v0,17,5,24,15,24v47,0,41,-75,54,-116","w":186},"\u00e0":{"d":"163,-226r-16,25r-78,-36r24,-38xm8,-54v4,-76,39,-134,112,-134v22,0,46,4,61,13v-11,34,-18,78,-27,115v-3,16,-2,27,7,36r-40,30v-9,-6,-13,-16,-14,-23v-32,37,-103,28,-99,-37xm126,-148v-50,-17,-70,53,-69,92v0,17,5,24,15,24v47,0,41,-75,54,-116","w":186},"\u00de":{"d":"109,-211v63,-3,104,10,104,58v0,69,-52,109,-138,100r-11,53r-52,0r54,-250r51,0xm84,-94v48,5,75,-10,75,-50v0,-29,-30,-27,-59,-26","w":207},"\u00dd":{"d":"184,-295r-86,37r-15,-27r83,-48xm238,-250r-112,147r-22,103r-52,0r22,-103r-47,-147r59,0r23,100r67,-100r62,0","w":195},"\u00dc":{"d":"221,-288v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm145,-288v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm239,-250r-36,168v-7,32,-13,49,-32,64v-10,7,-28,23,-75,23v-61,0,-85,-29,-74,-81r37,-174r52,0v-11,64,-33,126,-37,194v10,30,69,16,75,-13r39,-181r51,0","w":228},"\u00db":{"d":"220,-284r-19,27r-44,-28r-55,28r-13,-27r76,-48xm239,-250r-36,168v-7,32,-13,49,-32,64v-10,7,-28,23,-75,23v-61,0,-85,-29,-74,-81r37,-174r52,0v-11,64,-33,126,-37,194v10,30,69,16,75,-13r39,-181r51,0","w":228},"\u00da":{"d":"204,-295r-86,37r-15,-27r83,-48xm239,-250r-36,168v-7,32,-13,49,-32,64v-10,7,-28,23,-75,23v-61,0,-85,-29,-74,-81r37,-174r52,0v-11,64,-33,126,-37,194v10,30,69,16,75,-13r39,-181r51,0","w":228},"\u00d9":{"d":"195,-285r-17,26r-78,-36r24,-38xm239,-250r-36,168v-7,32,-13,49,-32,64v-10,7,-28,23,-75,23v-61,0,-85,-29,-74,-81r37,-174r52,0v-11,64,-33,126,-37,194v10,30,69,16,75,-13r39,-181r51,0","w":228},"\u00d7":{"d":"208,-163r-65,54r42,54r-39,32r-42,-54r-65,54r-25,-32r65,-54r-42,-54r39,-32r42,54r65,-54","w":221},"\u00d6":{"d":"229,-288v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm153,-288v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm244,-163v0,82,-46,168,-140,167v-62,0,-85,-38,-85,-90v0,-71,34,-122,66,-145v15,-11,36,-22,74,-22v55,0,85,34,85,90xm112,-35v59,2,73,-91,75,-139v0,-24,-10,-41,-37,-41v-59,1,-77,87,-77,137v0,32,14,43,39,43","w":246},"\u00d5":{"d":"224,-290v-15,15,-29,24,-50,24v-26,0,-51,-27,-71,-1r-12,-27v15,-15,28,-24,47,-24v26,0,53,29,74,2xm244,-163v0,82,-46,168,-140,167v-62,0,-85,-38,-85,-90v0,-71,34,-122,66,-145v15,-11,36,-22,74,-22v55,0,85,34,85,90xm112,-35v59,2,73,-91,75,-139v0,-24,-10,-41,-37,-41v-59,1,-77,87,-77,137v0,32,14,43,39,43","w":246},"\u00d4":{"d":"224,-284r-19,27r-44,-28r-55,28r-13,-27r75,-48xm244,-163v0,82,-46,168,-140,167v-62,0,-85,-38,-85,-90v0,-71,34,-122,66,-145v15,-11,36,-22,74,-22v55,0,85,34,85,90xm112,-35v59,2,73,-91,75,-139v0,-24,-10,-41,-37,-41v-59,1,-77,87,-77,137v0,32,14,43,39,43","w":246},"\u00d3":{"d":"218,-295r-86,37r-14,-27r83,-48xm244,-163v0,82,-46,168,-140,167v-62,0,-85,-38,-85,-90v0,-71,34,-122,66,-145v15,-11,36,-22,74,-22v55,0,85,34,85,90xm112,-35v59,2,73,-91,75,-139v0,-24,-10,-41,-37,-41v-59,1,-77,87,-77,137v0,32,14,43,39,43","w":246},"\u00d2":{"d":"198,-285r-17,26r-77,-36r23,-38xm244,-163v0,82,-46,168,-140,167v-62,0,-85,-38,-85,-90v0,-71,34,-122,66,-145v15,-11,36,-22,74,-22v55,0,85,34,85,90xm112,-35v59,2,73,-91,75,-139v0,-24,-10,-41,-37,-41v-59,1,-77,87,-77,137v0,32,14,43,39,43","w":246},"\u00d1":{"d":"213,-290v-15,15,-28,24,-49,24v-26,0,-51,-27,-71,-1r-12,-27v15,-15,28,-24,47,-24v26,0,53,29,74,2xm234,-250r-53,250r-52,0r-39,-179r-34,179r-49,0r53,-250r56,0v12,52,34,118,39,172v7,-60,21,-116,31,-172r48,0","w":225},"\u00d0":{"d":"60,-250v88,-2,164,-4,160,85v-4,81,-44,177,-152,165r-61,0r24,-110r-28,0r7,-32r27,0xm92,-41v58,7,74,-101,74,-125v0,-32,-22,-51,-63,-45r-14,69r38,0r-15,32r-30,0r-15,69r25,0","w":222},"\u00cf":{"d":"156,-288v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm80,-288v0,15,-12,28,-27,28v-15,0,-28,-13,-28,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm113,-250r-54,250r-52,0r53,-250r53,0","w":103},"\u00ce":{"d":"156,-284r-20,27r-44,-28r-54,28r-13,-27r75,-48xm113,-250r-54,250r-52,0r53,-250r53,0","w":103},"\u00cd":{"d":"149,-295r-86,37r-14,-27r83,-48xm113,-250r-54,250r-52,0r53,-250r53,0","w":103},"\u00cc":{"d":"131,-285r-17,26r-78,-36r24,-38xm113,-250r-54,250r-52,0r53,-250r53,0","w":103},"\u00cb":{"d":"200,-288v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm124,-288v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm203,-250r-15,41r-85,0r-13,58r71,0r-8,41r-71,0r-14,67r94,0r-9,43r-146,0r53,-250r143,0","w":174},"\u00ca":{"d":"202,-284r-20,27r-44,-28r-54,28r-13,-27r75,-48xm203,-250r-15,41r-85,0r-13,58r71,0r-8,41r-71,0r-14,67r94,0r-9,43r-146,0r53,-250r143,0","w":174},"\u00c9":{"d":"188,-295r-86,37r-15,-27r84,-48xm203,-250r-15,41r-85,0r-13,58r71,0r-8,41r-71,0r-14,67r94,0r-9,43r-146,0r53,-250r143,0","w":174},"\u00c8":{"d":"165,-285r-16,26r-78,-36r24,-38xm203,-250r-15,41r-85,0r-13,58r71,0r-8,41r-71,0r-14,67r94,0r-9,43r-146,0r53,-250r143,0","w":174},"\u00c7":{"d":"14,-84v0,-106,108,-219,205,-152r-29,33v-10,-9,-24,-13,-38,-13v-58,-1,-80,86,-81,134v-1,56,56,57,90,30r17,33v-25,17,-48,24,-80,23r-4,8v15,1,20,10,20,21v0,32,-50,51,-76,30r15,-22v9,12,45,-1,21,-9v-8,1,-12,3,-13,-5r13,-26v-38,-9,-60,-40,-60,-85","w":194},"\u00c5":{"d":"180,-295v0,21,-17,38,-38,38v-21,0,-38,-17,-38,-38v0,-21,18,-38,39,-38v21,0,37,17,37,38xm194,0r-53,0r-5,-59r-73,0r-30,59r-55,0r136,-251r54,0xm157,-295v0,-9,-6,-15,-14,-15v-9,0,-16,6,-16,15v0,9,7,16,15,16v9,0,15,-7,15,-16xm133,-101r-4,-95v-6,14,-34,73,-45,95r49,0","w":208},"\u00c4":{"d":"208,-288v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm132,-288v0,15,-13,28,-28,28v-15,0,-27,-13,-27,-28v0,-15,13,-28,28,-28v15,0,27,13,27,28xm194,0r-53,0r-5,-59r-73,0r-30,59r-55,0r136,-251r54,0xm133,-101r-4,-95v-6,14,-34,73,-45,95r49,0","w":208},"\u00c3":{"d":"207,-290v-15,15,-29,24,-50,24v-26,0,-51,-27,-71,-1r-11,-27v15,-15,27,-24,46,-24v26,0,53,29,74,2xm194,0r-53,0r-5,-59r-73,0r-30,59r-55,0r136,-251r54,0xm133,-101r-4,-95v-6,14,-34,73,-45,95r49,0","w":208},"\u00c2":{"d":"208,-284r-20,27r-44,-28r-54,28r-13,-27r75,-48xm194,0r-53,0r-5,-59r-73,0r-30,59r-55,0r136,-251r54,0xm133,-101r-4,-95v-6,14,-34,73,-45,95r49,0","w":208},"\u00c1":{"d":"203,-295r-86,37r-14,-27r83,-48xm194,0r-53,0r-5,-59r-73,0r-30,59r-55,0r136,-251r54,0xm133,-101r-4,-95v-6,14,-34,73,-45,95r49,0","w":208},"\u00c0":{"d":"185,-285r-17,26r-78,-36r24,-38xm194,0r-53,0r-5,-59r-73,0r-30,59r-55,0r136,-251r54,0xm133,-101r-4,-95v-6,14,-34,73,-45,95r49,0","w":208},"\u00b1":{"d":"177,-143r-8,41r-54,0r-11,52r-44,0r11,-52r-54,0r8,-41r54,0r11,-49r44,0r-11,49r54,0xm155,-41r-8,41r-151,0r8,-41r151,0","w":177},"\u00b0":{"d":"153,-196v0,34,-27,61,-61,61v-34,0,-61,-27,-61,-61v0,-34,27,-61,61,-61v34,0,61,27,61,61xm120,-196v0,-16,-12,-28,-28,-28v-16,0,-29,12,-29,28v0,16,13,29,29,29v16,0,28,-13,28,-29","w":138},"\u00ae":{"d":"294,-127v0,74,-59,133,-133,133v-74,0,-134,-59,-134,-133v0,-74,60,-134,134,-134v74,0,133,60,133,134xm258,-127v0,-56,-43,-102,-97,-102v-54,0,-98,46,-98,102v0,56,44,101,98,101v54,0,97,-45,97,-101xm221,-62r-41,0r-34,-54r0,54r-35,0r0,-137v47,-1,99,-5,99,42v0,21,-13,35,-31,37v16,6,38,55,42,58xm173,-157v1,-14,-12,-15,-27,-14r0,28v15,1,29,-2,27,-14","w":302},"\u00ac":{"d":"176,-111r-19,90r-44,0r11,-50r-115,0r9,-40r158,0","w":183},"\u00a9":{"d":"294,-127v0,74,-59,133,-133,133v-74,0,-134,-59,-134,-133v0,-74,60,-134,134,-134v74,0,133,60,133,134xm258,-127v0,-56,-43,-102,-97,-102v-54,0,-98,46,-98,102v0,56,44,101,98,101v54,0,97,-45,97,-101xm207,-71v-44,35,-110,7,-110,-54v0,-60,62,-95,106,-60r-16,23v-27,-19,-51,-8,-51,32v0,47,29,56,53,36","w":302},"\u00a6":{"d":"107,-272r-31,149r-46,0r32,-149r45,0xm66,-74r-32,149r-46,0r32,-149r46,0","w":95},"\u00b3":{"d":"83,-240v50,0,54,53,19,70v9,5,15,14,15,24v-5,49,-67,64,-112,57r-4,-26v32,6,67,0,74,-30v-2,-14,-26,-11,-37,-11r6,-29v18,2,41,3,42,-16v-6,-18,-38,-5,-48,4r-15,-23v19,-12,38,-20,60,-20","w":131},"\u00b2":{"d":"123,-203v0,34,-41,62,-69,83r60,0r-14,30r-99,0r5,-24v25,-22,76,-42,76,-81v0,-8,-4,-10,-11,-10v-8,0,-17,3,-34,15r-16,-23v22,-16,42,-23,65,-23v24,0,37,13,37,33","w":134},"\u00b9":{"d":"99,-234r-24,115r18,0r-6,29r-78,0r7,-29r23,0r16,-75v-8,4,-18,8,-30,12r-6,-20v26,-11,40,-35,80,-32","w":113},"\u00be":{"d":"326,-56r-6,30v-6,1,-17,-3,-17,4r-5,27r-36,4r8,-35r-64,0v11,-49,44,-78,64,-118r38,0r-56,88r25,0v4,-18,9,-33,15,-51r31,-6r-13,57r16,0xm329,-275r-260,330r-39,0r261,-330r38,0xm95,-240v51,0,54,54,18,70v9,5,15,14,15,24v-5,49,-67,64,-112,57r-4,-26v32,6,68,0,75,-30v-2,-16,-25,-10,-38,-11r6,-29v18,2,41,3,42,-16v-5,-18,-38,-5,-48,4r-14,-23v19,-12,38,-20,60,-20","w":348},"\u00bd":{"d":"310,-113v0,34,-42,63,-70,83r61,0r-14,30r-99,0r5,-24v25,-22,76,-42,76,-81v0,-8,-5,-10,-12,-10v-8,0,-17,3,-34,15r-15,-23v22,-16,41,-23,64,-23v24,0,38,13,38,33xm303,-275r-261,330r-38,0r260,-330r39,0xm110,-234r-24,115r18,0r-6,29r-77,0r6,-29r23,0r16,-75v-8,4,-18,8,-30,12r-6,-20v26,-11,39,-35,80,-32","w":329},"\u00bc":{"d":"307,-56r-6,30r-16,0v0,12,-4,20,-6,31r-35,4r7,-35r-64,0v11,-50,44,-78,65,-118r37,0r-55,88r24,0v4,-18,9,-33,15,-51r31,-6r-12,57r15,0xm311,-275r-261,330r-39,0r261,-330r39,0xm110,-234r-24,115r18,0r-6,29r-77,0r6,-29r23,0r16,-75v-8,4,-18,8,-30,12r-6,-20v26,-11,39,-35,80,-32","w":329},"\u00a0":{"w":81}}});

/* =========== END Cufon-yui ===== */


/* =========== BEGIN /_admin/js/overlay-apr2011/overlay.js =========== */

/*if (typeof(overlayOpen)!='function' && !$j('#nightShade').length) {*/

  function addLoadEvent(obj, evType, fn){
   if (obj.addEventListener){
     obj.addEventListener(evType, fn, false);
     return true;
   } else if (obj.attachEvent){
     var r = obj.attachEvent("on"+evType, fn);
     return r;
   } else {
     return false;
   }
  }


  addLoadEvent(window, 'load', function() {
    setTimeout(function() {

         $j('.iframeBox iframe').each(function(ix,el) {
             el.attr('src','support/images/spacer.gif');
         });

         $j(window).bind('beforeunload',overlayRemove);


      // overlays
      // insert overlay HTML and videoplayer overlay into page if not found
      if ($j('#overlayContent').length) {
        if (!$j('#videoOverlay').length) {
             $j('#overlayContent').append('<div id="videoOverlay" class="overlayPage video"><div class="videoID"><!-- dynamically populated when video links are clicked //--></div></div>');
        }
      } else {
        if ($j('#content').length) {
             $j('#content').before('<div id="overlayContent"><div id="videoOverlay" class="overlayPage video"><div class="videoID"><!-- dynamically populated when video links are clicked //--></div></div></div>');
        } else {
             $j('body').append('<div id="overlayContent"><div id="videoOverlay" class="overlayPage video"><div class="videoID"><!-- dynamically populated when video links are clicked //--></div></div></div>');
        }
        }

      // enable all links with class "overlayVideo"
      $j('.overlayVideo').live('click',function(ev) {
        var evEl=$j(ev.target).closest('.overlayVideo');
        if ($j(evEl).attr('videoplayer')!='' && $j(evEl).attr('videoplayer')!='undefined' && $j(evEl).attr('videoplayer')!=undefined) {
             $j('#videoOverlay').html('<div class="videoID" videoPlayer="'+$j(evEl).attr('videoplayer')+'" playerKey="'+$j(evEl).attr('videoplayerkey')+'">'+$j(evEl).attr('videoid')+'</div>');
        } else {
             $j('#videoOverlay').html('<div class="videoID">'+$j(evEl).attr('videoid')+'</div>');
        }
        openOverlay('videoOverlay');
        ev.preventDefault();
      });

      // enable all links with class "overlayIframe"
      $j('.overlayIframe').click(function(ev) {
        var evEl=$j(ev.target).closest('.overlayIframe');
        if ($j('#iframeOverlay').length==0) {
             $j('#nightShadeContainerContent').append('<div id="iframeOverlay" class="overlayPage" style="background-color: #ffffff;"><iframe src="'+evEl.attr('href')+'" width="960" height="540" frameborder="0" scrolling="no"/></div>');
        } else {
             $j('#iframeOverlay iframe').remove();
             $j('#iframeOverlay').append('<iframe src="'+evEl.attr('href')+'" width="960" height="540" frameborder="0" scrolling="no"/>');
        }
        if (evEl.attr('overlayWidth')!='undefined') {
             $j('#iframeOverlay iframe').attr('width',evEl.attr('overlayWidth'));
        }
        if (evEl.attr('overlayHeight')!='undefined') {
             $j('#iframeOverlay iframe').attr('height',evEl.attr('overlayHeight'));
        }
        if (evEl.attr('overlayScrolling')!='undefined') { // yes or no
             $j('#iframeOverlay iframe').attr('scrolling',evEl.attr('overlayScrolling'));
        }
        $j('#iframeOverlay').css('padding','0px');
        if (evEl.attr('overlayPadding')!='undefined') { // valid CSS values
             $j('#iframeOverlay').css('padding',evEl.attr('overlayPadding'));
        }
        openOverlay('iframeOverlay');
        ev.preventDefault();
      });

      if ($j('#overlayContent').length && !$j('#nightShade').length) {
        nsHTML='<div id="nightShade"></div><div id="nightShadeContainer"><table id="nightShadeContainerInner" cellpadding="0" cellspacing="0" border="0"><tr><td align="center" valign="top"><div id="nightShadeContainerInnerCollapser">';
        if (!isIE6) {
             nsHTML+='<div id="nightShadeShadowTL"></div><div id="nightShadeShadowTC"></div><div id="nightShadeShadowTR"></div><div id="nightShadeShadowML"></div><div id="nightShadeShadowMR"></div><div id="nightShadeShadowBL"></div><div id="nightShadeShadowBC"></div><div id="nightShadeShadowBR"></div>';
        }
        nsHTML+='<div id="nightShadeContainerContent"></div><div id="nightShadeClose"></div><div class="clearBothTight"></div></div><div class="clearBothTight"></div></td></tr></table></div>';
        $j('body').prepend(nsHTML);

        $j('#nightShadeContainerContent').html($j('#overlayContent').html());
        $j('#overlayContent').remove();
        try { Cufon.refresh(); } catch(err) {}
        $j('#nightShade').click(overlayRemove);
        $j('#nightShadeClose').click(overlayRemove);
        $j('#nightShadeShadowTL').click(overlayRemove);
        $j('#nightShadeShadowTC').click(overlayRemove);
        $j('#nightShadeShadowTR').click(overlayRemove);
        $j('#nightShadeShadowML').click(overlayRemove);
        $j('#nightShadeShadowMR').click(overlayRemove);
        $j('#nightShadeShadowBL').click(overlayRemove);
        $j('#nightShadeShadowBC').click(overlayRemove);
        $j('#nightShadeShadowBR').click(overlayRemove);
        $j('#nightShadeContainer').click(overlayRemoveWrapper);
        $j('#nightShade').css({opacity:0});
        $j('#nightShadeContainer').css({opacity:0});

        if (isIE6) { // needed for ie6 only
             $j('#nightShade').css({position:'absolute'});
             $j('#nightShadeContainer').css({position:'absolute'});
             $j(window).bind('resize',nightShadeUpdate);
             $j(window).bind('scroll',nightShadeUpdate);
             nightShadeUpdate();
        }

        if (isIE7or8) {
           var fixList=['nightShadeShadowTL',
                        'nightShadeShadowTC',
                        'nightShadeShadowTR',
                        'nightShadeShadowML',
                        'nightShadeShadowMR',
                        'nightShadeShadowBL',
                        'nightShadeShadowBC',
                        'nightShadeShadowBR'
                        ];
           for (i=0;i<fixList.length;i++) {
                var temp=$j('#'+fixList[i]).css('background-image');
                temp=temp.replace('url("','');
                temp=temp.replace('")','');
                $j('#'+fixList[i]).css({backgroundImage:'none'});
                var filterString='progid:DXImageTransform.Microsoft.AlphaImageLoader(src="'+temp+'", sizingMethod="crop", enabled="true");';
                $j('#'+fixList[i]).css({filter:filterString});
           }
        }

        //setup overlay links
        $j('.overlayLink').each(function(ix,el) {
           $j(el).click(function(ev) {
                var evEl=$j(ev.target).closest('a');
              //remove OVERLAY: from HREF, in the future this can be checked to allow different triggers or alternate setups
                if ($j('nightShade')) {
                 openOverlay($j(evEl).attr('overlay'));
              }
                ev.preventDefault();
           });
        })

        //play video again links
        $j('.playVideoAgain').each(function(ix,el) {
          $j(el).click(function(ev) {
            doVideo(cOverlay);
          });
        });

      }

    },50);
    //end setTimeout

  });
  // end addLoadEvent


  /* NIGHTSHADE/OVERLAY SCRIPTS */

  var hasOpenedAnOverlay=false; // for tracking whether an overlay has been opened, used to prevent Firefox unlocking content after a reload


  var cOverlay='';
  var overlayIsOpen=false;
  function openOverlay(which) {

      if ($j('#nightShade')) {

      //run overlay's UNinit func if registered
      if (overlayUnInitFuncs[cOverlay]) {
          overlayUnInitFuncs[cOverlay].call();
      }

      /* FIX PNGS in IE6 */
      if (isIE6) {
           DD_belatedPNG.fix('.pngFixRule2,#nightShadeClose img');
      }

      hasOpenedAnOverlay=true;
      if (cOverlay=='') {
          $j('#nightShade').css({opacity:0});
          $j('#nightShadeContainer').css({opacity:0});
      }
      if (cOverlay!=which) {
           cOverlay=which;
           $j('.overlayPage').each(function(ix,el) {
               if ($j(el).attr('id')==which) {
             $j(el).css({display:'block'});
             $j(el).css({visibility:'visible'});
               } else {
             $j(el).css({display:'none'});
             $j(el).css({visibility:'hidden'});
               }
           });

          //update any iframes for market first as needed
          if ($j('#'+cOverlay).find('.form').length) {
          // if (isLocalhost) {
                  /* DEBUG ONLY */
                  // $j('#'+cOverlay).find('.iframeElement')[0].src=((formAlreadySubmitted)?'/_admin/js/overlay-apr2011/fake-form-post.htm':'/_admin/js/overlay-apr2011/fake-form.htm');
          // } else {
                  /* PRODUCTION */
                  $j('#'+cOverlay).find('.iframeElement')[0].src=$j('#'+cOverlay).find(((formAlreadySubmitted)?'.iframeURLpost':'.iframeURLpre'))[0].innerHTML.split('&amp;').join('&');
          // }
          if (formAlreadySubmitted) {
                  $j('#'+cOverlay).find('.iframeElement')[0].style.display='none';

              //Omniture DO NOT REMOVE!!!!!!!!
              //trackLead();
              ///////////////////////////////
          }
          }

      }

      // do actual overlay opening or bypass straight to download
      // swap comments to block auto-opening download assets when following next asset links
      if (!overlayIsOpen && $j('#'+cOverlay).hasClass('download') && ($j('#'+cOverlay).find('.form').length==0 || formAlreadySubmitted)) {
      //if ($j('#'+cOverlay).hasClassName('download') && ($j('#'+cOverlay).select('.form').length==0 || formAlreadySubmitted)) {

           //doesn't need overlay, skip straight to download file
           var dlURL=$j('#'+cOverlay).find('.downloadLink').eq(0).attr('href');
           if (dlURL.indexOf('.pdf')>=0) {
        window.open(dlURL);
           } else {
        window.location=dlURL;
           }
           //overlayRemove();

      } else {

           //needs overlay shown

           overlayIsOpen=true;
           $j('#nightShade').css({display:'block'});
           $j('#nightShadeContainer').css({display:'block'});

                 $j('#nightShade').animate({
                   opacity: 0.6,
                   framerate: 30
                 },600);
                 $j('#nightShadeContainer').animate({
                   opacity: 1,
                   framerate: 30
                 },600,function() {
               $j('#nightShadeContainer').css('filter','none');
             });

           //setup and initialize content post-overlay opening

           //do video for video overlays if registered and either not protected or form already submitted
           if ($j('#'+cOverlay).hasClass('video') && ($j('#'+cOverlay).find('.form').length==0 || formAlreadySubmitted)) {
         doVideo($j('#'+cOverlay));
           }

           // hide close button on apple devices if video overlay (iOS blocks clickabilty in this case)
           if ($j('#'+cOverlay).hasClass('video') && emcghf.isIOS) {
            $j('#nightShadeClose').css({display:'none'});
           } else {
            $j('#nightShadeClose').css({display:'block'});
           }

      }

      //run overlay's init func if registered and either not protected or form already submitted
      try {
          if (overlayInitFuncs[cOverlay] && ($j('#'+cOverlay).find('.form').length==0 || formAlreadySubmitted)) {
             overlayInitFuncs[cOverlay].call();
          }
      } catch (err) {
          // do nothing, just here to avoid errors on init func preventing overlay opening
      }

      } // end if ($j('#nightShade'))

  } // end openOverlay

  function overlayRemove(ev) {

    if (typeof(carousels)=='Array') {
      for (var wth=0;wth<carousels.length;wth++) {
           if (carousels[wth].rotateDelay!=0) {
                rotate(wth,true);
           }
      }
    }
      if (cOverlay!='') {
      overlayIsOpen=false;
      //run overlay's UNinit func if registered
      try {
          if (overlayUnInitFuncs[cOverlay]) {
             overlayUnInitFuncs[cOverlay].call();
          }
      } catch (err) {
          //do nothing, just here to avoid errors on uninit func preventing overlay closure
      }
      if ($j('#'+cOverlay).hasClass('video')) {
         if (modVP) { if (typeof(modVP.stop)!='undefined') { modVP.stop(); } }
         if (modExp) { if (typeof(modExp.unload)!='undefined') { modExp.unload(); } }
         modVP={};
         modExp={};
          $j('#'+cOverlay).find('.videoTarget').remove();
      }
  if (cOverlay=='iframeOverlay') {
          $j('#iframeOverlay').empty();
        }

      cOverlay='';

      $j('#nightShade').animate({
         opacity: 0,
         framerate: 30
      },600);
      $j('#nightShadeContainer').animate({
         opacity: 0,
         framerate: 30
      },600,function() {
              $j('#nightShade').css({display:'none'});
              $j('#nightShadeContainer').css({display:'none'});
              $j('#nightShade').css({filter:''});
              $j('#nightShadeContainer').css({filter:''});
              $j('.overlayPage').each(function(ix,el) {
                  $j(el).css({display:'none'});
              });
      });

      }
  } // end overlayRemove

  function overlayRemoveWrapper(ev) {
      if ($j(ev.target).attr('id')=='nightShadeContainer') {
    overlayRemove();
    ev.preventDefault();
      }
  } // end overlayRemoveWrapper

  function nightShadeUpdate() { // needed for ie6 only
    winSize={};
    winSize.width = document.documentElement.clientWidth;
    winSize.height = document.documentElement.clientHeight;//$j(document.body).height();//documentElement.clientHeight;
    if ($j('#nightShade') ) {
         $j('#nightShade').css({width:winSize.width+'px'});
         $j('#nightShade').css({height:(winSize.height+100)+'px'});
         //$j('#nightShade').css({top:(document.viewport.getScrollOffsets().top-50)+'px'});
         //$j('#nightShadeContainer').css({top:document.viewport.getScrollOffsets().top+'px'});
         $j('#nightShadeContainer').css({width:Math.max(1000,winSize.width)+'px'});
         $j('#nightShadeContainer').css({height:(winSize.height)+'px'});
         pageFix=$j(document.body).offset();
         $j('#nightShade').css({left:(0-pageFix.left)+'px'});
         $j('#nightShadeContainer').css({position:'absolute'});
         $j('#nightShadeContainer').css({left:(0-pageFix.left)+'px'});
    }
  } // end nightShadeUpdate


  function resizeIframe() { /* DOES NOTHING, JUST HERE TO PREVENT JS ERRORS */ }

  var formAlreadySubmitted=false;
  var userEmail=false;
  var preFormSubmitted=false;
  var hasOpenedAnOverlay=false;
  //function contactSubmitted(inEmail) {
  //    unlockContent(inEmail); //pass-through so either function works
  //}
  //function unlockContent() {
  //     // do nothing, override this function to add unlock functionality after Aprimo form submission
  //}


  /* VIDEOPLAYER SUPPORT */
  //dynamically load and add brightcove JS files

  var overlayHTML='';
  var bcInterval;
  function doVideo(el) {
       if (el!=undefined) {
            overlayHTML = '<object id="emcExperience" class="BrightcoveExperience">' +
                 '<param name="bgcolor" value="#000000" />';

            //JUST USE PIXEL SETTINGS FOR ALL SINCE SAFARI 5 ALSO DIDN'T LIKE 100%
            overlayHTML += '<param name="width" value="'+$j('#'+cOverlay).width()+'" /><param name="height" value="'+$j('#'+cOverlay).height()+'" />';

            overlayHTML += '<param name="isVid" value="true" />' +
                 '<param name="isUI" value="true" />' +
                 '<param name="autoStart" value="true" />' +
                 '<param name="dynamicStreaming" value="true" />' +
                 '<param name="templateErrorHandler" value="onPlayerError" />' +
                 '<param name="wmode" value="transparent" />';

        if (el.find('.videoID').attr('videoPlayer')!=undefined) {
           overlayHTML += '<param name="playerID" value="' + el.find('.videoID').attr('videoPlayer') + '" />' +
                 '<param name="playerKey" value="' + el.find('.videoID').attr('playerKey') + '" />';
        } else {
           overlayHTML += '<param name="playerID" value="949252753001" />' +
                 '<param name="playerKey" value="AQ~~,AAAAoc2nJVE~,yIQzUe15OpLcz7KPrk2AqKId2oggWw7T" />';
        }

         if (window.location.protocol=='https:') {
           overlayHTML += '<param name="secureConnections" value="true" />';
         }

        overlayHTML += '<param name="@videoPlayer" value="'+el.find('.videoID').first().html().replace('BC:','').replace('bc:','').replace('Bc:','')+'" />' +

                 '</object>';
            if (overlayHTML!='') {
         if (modVP) { if (typeof(modVP.stop)!='undefined') { modVP.stop(); } }
         if (modExp) { if (typeof(modExp.unload)!='undefined') { modExp.unload(); } }
         modVP={};
         modExp={};
           $j('#'+cOverlay).find('.videoTarget').remove();
           $j('#'+cOverlay).append('<div class="videoTarget">'+overlayHTML+'</div>');
                 bcInterval=setInterval(function(){
                      try {
                           if (brightcove) {
                                brightcove.createExperiences();
                                clearInterval(bcInterval);
                           }
                      } catch(err) {
                           //brightcove scripts not loaded yet, do nothing
                      }
                 },50);
            }
       }
  }


  // BRIGHTCOVE SUPPORT
  var modVP;
  var bcExp;
  var modExp;
  var modControls;
  function onTemplateLoaded(experienceID) {
    try {
      bcExp = brightcove.getExperience(experienceID);
      modVP = bcExp.getModule(APIModules.VIDEO_PLAYER);
      modExp = bcExp.getModule(APIModules.EXPERIENCE);
      modVP.addEventListener('mediaProgress', checkVidProgress );
    } catch(err) {}
  }

  function onPlayerError(ev) {
    //do nothing
  }

  function checkVidProgress(ev) {
      var perc=ev.position/modVP.getVideoDuration();
      if (perc>0.999) {
      if (!$j('#'+cOverlay).hasClass('isLive')) {
          //remove VP at end if there is "showAfterUnlock" content, returning user to overlay which shows new content, otherwise remain in place
          $j('#'+cOverlay).find('.showAfterUnlock').css({display:'block'});
          // kill and remove VP
         if (modVP) { if (typeof(modVP.stop)!='undefined') { modVP.stop(); } }
         if (modExp) { if (typeof(modExp.unload)!='undefined') { modExp.unload(); } }
         modVP={};
         modExp={};
          $j('#'+cOverlay).find('.videoTarget').remove();
      }
      }
  }

  var overlayInitFuncs={};
  function registerOverlayInitScript(overlayName,func) {
       overlayInitFuncs[overlayName]=func;
  }
  var overlayUnInitFuncs={};
  function registerOverlayUnInitScript(overlayName,func) {
       overlayUnInitFuncs[overlayName]=func;
  }

/*}*/

/* =========== END /_admin/js/overlay-apr2011/overlay.js =========== */



/* =========== BEGIN HEADER JAVASCRIPT ============= */
var $j=jQuery.noConflict();
var isIE6=(window.XMLHttpRequest==undefined && ActiveXObject!=undefined);
var isIE7=(jQuery.browser.msie && jQuery.browser.version==7);
var isIE8=(jQuery.browser.msie && jQuery.browser.version==8);
var isIE9=(jQuery.browser.msie && jQuery.browser.version==9);
var isIE7or8=(isIE7 || isIE8);
var isIE9plus=isIE9;


var isIOS=(window.location.href.indexOf('?forceios')>=0 || navigator.userAgent.toLowerCase().search('android')>=0 || navigator.userAgent.toLowerCase().search('iphone')>=0 || navigator.userAgent.toLowerCase().search('ipad')>=0 || navigator.userAgent.toLowerCase().search('ipod')>=0);
var emcghf={};
emcghf.isIOS=(window.location.href.indexOf('?forceios')>=0 || navigator.userAgent.toLowerCase().search('android')>=0 || navigator.userAgent.toLowerCase().search('iphone')>=0 || navigator.userAgent.toLowerCase().search('ipad')>=0 || navigator.userAgent.toLowerCase().search('ipod')>=0);

var isiPad = navigator.userAgent.match(/iPad/i) != null;

var menuItems;
var dropDowns;
var ddAnimTime=250;
var ddOpenTimeout;
var ddSwitchTimeout;
var ddIsOpen = false;
var menuWidth = $j('#menu').width();
var gscEmailUsLinkHTML;

currentDD=-1;

var tryDDtimeout;

/* block selection of text, used to prevent accidental selection during interaction esp. in IE */
function disableSelection(target){
if (typeof target.onselectstart!="undefined") //IE route
     target.onselectstart=function(){return false}
else if (typeof target.style.MozUserSelect!="undefined") //Firefox route
     target.style.MozUserSelect="none"
else //All other route (ie: Opera)
     target.onmousedown=function(){return false}
//target.style.cursor = "default"
}


$j(window).load(function(){
     if ($j('html').hasClass('legacy')) {
          if ($j('body').hasClass('no-menudropdowns')) {
               initDropdowns();
          } else {
               tryDDtimeout=setTimeout(tryDropdowns,250);
          }
     } else {
       initDropdowns();
     }

     //if ($j('body').hasClass('large')) {
       //initDropdowns();
     //} else {
       //flag for hp.homepage.js
      // $j('#dropDowns').hide().addClass('not-ini');
       //$j('#headerWrap').height('77px');
     //}

});



// BEGIN BRIGHTCOVE SUPPORT

var modVP;
var bcExp;
var modExp;
var modControls;
function onTemplateLoaded(experienceID) {
  try {
    bcExp = brightcove.getExperience(experienceID);
    modVP = bcExp.getModule(APIModules.VIDEO_PLAYER);
    modExp = bcExp.getModule(APIModules.EXPERIENCE);
    modVP.addEventListener('mediaProgress', checkVidProgress );
  } catch(err) {}
}

function onPlayerError(ev) {
  //do nothing
}

function checkSize(initialWidth) {
  var $body = $j("body");
  //console.log("checkSize: ", initialWidth);
    // Desktop
    if (initialWidth >= mediumSize) {
        if (!$body.hasClass('large')) {
            $body.removeClass('small medium').addClass('large');
            if (typeof(inboundBar)!="undefined"){inboundBar.closeAll();}
        }
        else {
            return false;
        }
    }
    // Tablet
    else if (initialWidth < mediumSize && initialWidth > smallSize) {
        if ($body.hasClass('large')) startCloseDropdowns();
        if (!$body.hasClass('medium')) {
            $body.removeClass('small large').addClass('medium');
      if (typeof(inboundBar)!="undefined"){inboundBar.closeAll();}
        }
        else {
            return false;
        }
    }
    // Phone
    else if (initialWidth <= smallSize) {
        if ($body.hasClass('large')) startCloseDropdowns();
        if (!$body.hasClass('small')) {
            $body.removeClass('medium large').addClass('small');
      if (typeof(inboundBar)!="undefined"){inboundBar.closeAll();}
        }
        else {
            return false;
        }

    }
    $j(window).trigger("windowResized");
}

function checkVidProgress(ev) {
    var perc=ev.position/modVP.getVideoDuration();
    if (perc>0.999) {
  if (!$j('#'+cOverlay).hasClass('isLive')) {
      //remove VP at end if there is "showAfterUnlock" content, returning user to overlay which shows new content, otherwise remain in place
      $j('#'+cOverlay).find('.showAfterUnlock').css({display:'block'});
      // kill and remove VP
            if (modVP) { modVP.stop(); }
      if (modExp) { modExp.unload(); }
      $j('#'+cOverlay).find('.videoTarget').remove();
  }
    }
}

var overlayInitFuncs={};
function registerOverlayInitScript(overlayName,func) {
     overlayInitFuncs[overlayName]=func;
}
var overlayUnInitFuncs={};
function registerOverlayUnInitScript(overlayName,func) {
     overlayUnInitFuncs[overlayName]=func;
}

// END BRIGHTCOVE SUPPORT



function tryDropdowns() {
     // only do this after finding dropdowns present
     // compensates for slower loads in freeform pages due to using JS to load dropdowns
     if ($j('#dropDowns').length) {
          initDropdowns();
     } else {
          tryDDtimeout=setTimeout(tryDropdowns,250);
     }
}

var emcPlusDDCheckIntervals=[];

function initDropdowns() {
     //jQuery.framerate({framerate: 30, logframes: false});
     jQuery.easing.def='easeInOutQuad';

     // dropdown menu setup
     menuItems=$j('.menuItem');
     dropDowns=$j('.dropdownItem');
     var ddEvent = (isiPad) ? 'click' : 'mouseenter';
     $j(menuItems).each(function(ix,el) {
	$j(el).attr('title','');
	disableSelection(el);
          $j(el).attr('ddID',ix);
          $j(el).attr('ix',ix);
          $j('.dropdownItem').eq(ix).attr('ix',ix);
          $j(el).bind(ddEvent,function(ev) {
                    ev.preventDefault();

                    var tgMenu = $j(ev.target).closest('a.menuItem');

              // capture clicks on iPad if menu is already opened
        if (isiPad && ddIsOpen && $j(tgMenu).attr('ddID') == currentDD) {
             window.location = $j(this).attr('href');
             return false;
                    }

                    currentDD = $j(tgMenu).attr('ddID');
                    var tgEl=$j(dropDowns[$j(tgMenu).attr('ddID')]);


                    ddIsOpen = true;

                    clearTimeout(ddSwitchTimeout);
                    ddSwitchTimeout=setTimeout(function() {
                         updateDropdownHeight(); // first instance to trigger final layout only, animation will be cancelled by second call below
                         $j(dropDowns).each(function(ix1,el1) {
                              if (ix1==currentDD) {
                                   $j(el1).show();
                                   $j(el1).attr('isOpen',true);
                              } else {
                                   $j(el1).hide();
                                   $j(el1).attr('isOpen',false);
                              }
                         });
                         $j(menuItems).each(function(ix1,el1) {
                              if (ix1==currentDD) {
                                   $j(el1).addClass('on');
                              } else {
                                   $j(el1).removeClass('on');
                              }
                         });
                         if ($j('.menuItem').eq(currentDD).hasClass('current')) {
                            $j('#dropDownIndicator .current').css({ display: 'block'});
                              $j('#dropDownIndicator .normal').css({ display: 'none'});
                         } else {
                              $j('#dropDownIndicator .current').css({ display: 'none'});
                              $j('#dropDownIndicator .normal').css({ display: 'block'});
                         }
                         $j('#dropDownIndicator').css({
                             left: ($j('#menu').position().left+$j('.menuItem').eq(currentDD).position().left+($j('.menuItem').eq(currentDD).width()/2)+10)+'px'
                        });
                         $j('#dropDownIndicator div img,#dropDownIndicator div div').css({
                             top: '0px'
                         });
                         updateDropdownHeight();
                    },(200));
        clearTimeout(ddOpenTimeout);
                    //if ($j('#dropDowns').length) {

                         //ddOpenTimeout=setTimeout(openDropdowns,ddAnimTime*2);
                    //}

          });
    if (/*!isIOS &&*/ !isiPad || isTablet()) {
      // kill menu opening on click on desktop so it doesn't open when clicking a menu button
      $j(el).bind('click',function(ev) {
                    clearTimeout(ddOpenTimeout);
      });
    }
          if ($j('#dropDowns').length) {
               $j(el).mouseleave(function(ev) {
                    clearTimeout(ddOpenTimeout);
                    clearTimeout(ddSwitchTimeout);
               });
          }
     });

     // Dropdowns-only stuff, don't run if dropdowns aren't in page
     if ($j('#dropDowns').length) {

          $j(dropDowns).each(function(ix,el) {
               disableSelection(el);
               if (ix==0) {
                    $j(el).show();
                    $j(el).attr('isOpen',true);
               } else {
                    $j(el).hide();
                    $j(el).attr('isOpen',false);
               }
          });

           // store for later
          gscEmailUsLinkHTML=$j('#gscEmailUsLinkHTML').html();

          // add and process email and global sales contacts overlays

            // overlays
            // insert overlay HTML and videoplayer overlay into page if not found
            // necessary here because How To Buy was doing this wrong
            if ($j('#overlayContent').length) {
                if (!$j('#videoOverlay').length) {
                    $j('#overlayContent').append('<div id="videoOverlay" class="overlayPage video"><div class="videoID"><!-- dynamically populated when video links are clicked //--></div></div>');
                }
            } else {
         if ($j('#content').length) {
        $j('#content').before('<div id="overlayContent"><div id="videoOverlay" class="overlayPage video"><div class="videoID"><!-- dynamically populated when video links are clicked //--></div></div></div>');
         } else {
        $j('body').append('<div id="overlayContent"><div id="videoOverlay" class="overlayPage video"><div class="videoID"><!-- dynamically populated when video links are clicked //--></div></div></div>');
         }
            }

    if ($j('#overlayContent').length) {
         $j('#overlayContent').append('<div id="globalSalesContactsOverlay" class="overlayPage">'+$j('#gscContentHolder').html()+'</div>');
         $j('#overlayContent').append('<div id="globalSalesContactsFormOverlay" class="overlayPage">'+$j('#gscFormContentHolder').html()+'</div>');
         $j('#overlayContent').append('<div id="emailUsOverlay" class="overlayPage">'+$j('#emailUsContentHolder').html()+'</div>');
    } else {
         $j('#nightShadeContainerContent').append('<div id="globalSalesContactsOverlay" class="overlayPage">'+$j('#gscContentHolder').html()+'</div>');
         $j('#nightShadeContainerContent').append('<div id="globalSalesContactsFormOverlay" class="overlayPage">'+$j('#gscFormContentHolder').html()+'</div>');
         $j('#nightShadeContainerContent').append('<div id="emailUsOverlay" class="overlayPage">'+$j('#emailUsContentHolder').html()+'</div>');
    }
          $j('#globalSalesContactsOverlayLink, #leadSpace .leftCol .overlayLink').click(function(ev) {
         //if (loginURL.indexOf(window.location.host)>=0) {
        // on EMC.com
        $j('#globalSalesContactsList').load('/products/how-to-buy/global-sales-contacts-include.txt',function() {
       $j('.salesContactRow').each(function(ix,el) {
            if (ix%2) { $j(el).addClass('gray'); }
            $j(el).find('.clearBothTight').before(gscEmailUsLinkHTML);
       });
       $j('.contactListAlphaLink').live('click',function(ev) {
            var evEl=$j(ev.target);
            var targEl=$j('#row'+$j(evEl).html());
            if (targEl.length) { $j('#globalSalesContactsList').scrollTo(targEl,500,{ease:'easeInOutQuad'}); }
            ev.preventDefault();
            return false;
       });
       $j('.salesContactRow .email').live('click',function(ev) {
            var evEl=$j(ev.target);
            $j('#gscif').attr('src',$j(evEl).attr('href'));
            openOverlay('globalSalesContactsFormOverlay');
            ev.preventDefault();
            return false;
       });
        });
        openOverlay('globalSalesContactsOverlay');
         //} else {
    //    // off EMC.com, fall back to linking through to EMC.com HtB page due to cross-domain issues
    //    window.location.href=loginURL.slice(0,loginURL.indexOf('/l'))+'/products/how-to-buy/index.htm?gsc';
         //}
         ev.preventDefault();
         return false;
          });
          // override old How To Buy page functionality for compatibility with new header
          $j('#leadSpace .rightCol .overlayLink').each(function(ix,el) {
            $j(el).removeClass('overlayLink').addClass('emailUsOverlayLink').unbind();
          });
          $j('.emailUsOverlayLink, #leadSpace .rightCol .overlayLink').click(function(ev) {
       var evEl=$j(ev.target).closest('a,.simulatedA');
         //if (loginURL.indexOf(window.location.host)>=0) {
        // on EMC.com
        $j('#emailif').attr('src',$j(evEl).attr('href'));
        openOverlay('emailUsOverlay');
        $j('#emailif').attr('scrolling','no');
         //} else {
    //    // off EMC.com, fall back to linking through to EMC.com HtB page due to cross-domain issues
    //    window.location.href=loginURL.slice(0,loginURL.indexOf('/l'))+'/products/how-to-buy/index.htm?email';
         //}
         ev.preventDefault();
         return false;
          });

      /* NEW HERE */ $j('.overlayContentTempHolder').remove();


          // debugging, force open for quick layout check
          if (window.location.search!='' && window.location.search.indexOf('?forcemenu=')>=0) {
               var temp=window.location.search.replace('?forcemenu=','');
               temp=temp.split(',');
               $j(menuItems[Number(temp[0])]).mouseenter();
               if (temp.length>1) {
                    setTimeout(function() {
                         $j(dropDowns[Number(temp[0])]).find('.dropDownTab').eq(Number(temp[1])).click();
                    },200);
               }
          }

          // close dropdown events
          $j('body, #dropDowns').mouseleave(startCloseDropdowns);
          $j('#content, #headerTop').mouseenter(startCloseDropdowns);

          // Dropdown Carousels
     $j('#dropDowns .universalCarousel').each(function(ix,el) {
         universalCarousels.init($j(el).attr('id'));
         universalCarousels.start($j(el).attr('id'));
    });


          // Dropdown Tabs -- must come after carousel inits
        /*  $j('.dropDownTabs').each(function(ix0,el0) {
       $j(el0).find('.dropDownTab').each(function(ix,el) {
    $j(el).attr('ix',ix);
    $j(el).click(function(ev) {
         var evEl=$j(ev.target).closest('.dropDownTab');
         var tgEl=$j(evEl).closest('.dropDownTabs').siblings('.dropDownTabBodies').find('.dropDownTabBody').eq($j(el).attr('ix'));
         $j(evEl).addClass('on');
         $j(evEl).siblings('.dropDownTab').removeClass('on');
         $j(tgEl).show();
         currentDD=Number($j(evEl).closest('.dropdownItem').attr('ix'));
         $j(tgEl).siblings('.dropDownTabBody').hide();
                         updateDropdownHeight(); //C
    });
    $j(el).closest('.dropDownTabs').siblings('.dropDownTabBodies').find('.dropDownTabBody').eq(0).show();
    $j(el).closest('.dropDownTabs').siblings('.dropDownTabBodies').find('.dropDownTabBody').eq(0).siblings('.dropDownTabBody').hide();
       });
          });*/

          // Simulated <a> tags
          $j('span.simulatedA').each(function(ix,el) {
               // replicate <a> hover
               $j(el).mouseenter(function(ev) {
                    var evEl=$j(ev.target).closest('span.simulatedA');
                    $j(evEl).addClass('hover');
               });
               $j(el).mouseleave(function(ev) {
                    var evEl=$j(ev.target).closest('span.simulatedA');
                    $j(evEl).removeClass('hover');
               });
               // click since SEO requires these links not be <a> tags
               $j(el).click(function(ev) {
                    var evEl=$j(ev.target).closest('span.simulatedA');
                    var isInCarousel=$j(ev.target).closest('.universalCarousel').length;
                    if ($j(evEl).attr('href')!='#' && !$j(evEl).hasClass('nullLink')) {
                         // only activate length if it's not in a carousel
                         // or if it is only if it's stationary
                         /* CHANGE JULY 2014: Support inactive carousels as if they weren't carousels */
                         if (typeof(universalCarousels.carousels[$j(evEl).closest('.universalCarousel').attr('id')])=='undefined') {
                              activateSimulatedA($j(evEl).attr('href'),($j(evEl).attr('target')=='_blank'));
                         } else if (!isInCarousel || !universalCarousels.carousels[$j(evEl).closest('.universalCarousel').attr('id')].config.cVel) {
                              activateSimulatedA($j(evEl).attr('href'),($j(evEl).attr('target')=='_blank'));
                         }
                    }
               });
          });

          // Support Locale Cookie
    // add Array.indexOf method to IE<=8
    if(!Array.prototype.indexOf){Array.prototype.indexOf=function(searchElement){"use strict";if(this==null){throw new TypeError();} var t=Object(this);var len=t.length>>>0;if(len===0){return-1;} var n=0;if(arguments.length>0){n=Number(arguments[1]);if(n!=n){n=0;}else if(n!=0&&n!=Infinity&&n!=-Infinity){n=(n>0||-1)*Math.floor(Math.abs(n));}} if(n>=len){return-1;} var k=n>=0?n:Math.max(len-Math.abs(n),0);for(;k<len;k++){if(k in t&&t[k]===searchElement){return k;}} return-1;}}
    var languageArr = ['en','fr','de','ru','es','ko','ja','it','pt','zh'];
    var date = new Date();
    date.setTime(date.getTime()+(30*24*60*60*1000));
    if (typeof(emcDomainMap[subDomain.split('-').join('')])!='undefined') {
         if (languageArr.indexOf(emcDomainMap[subDomain.split('-').join('')].slice(0,2))>=0) {
        document.cookie = "PREFLANG=" + emcDomainMap[subDomain.split('-').join('')] + "; expires=" + date.toGMTString() + "; path=/; domain=emc.com;";
         }
    } else {
         document.cookie = "PREFLANG=" + emcDomainMap['www'] + "; expires=" + date.toGMTString() + "; path=/; domain=emc.com;";
    }

    // set domain cookie so we know what EMC.com domain visitor was on last
    // but only on EMC.com domains (not store or support or ECN)
    // this is being added to support Store
    if (!isRemoteSite()){
      //document.cookie = "LASTEMCDOMAIN=" + window.location.hostname + "; expires=" + date.toGMTString() + "; path=/; domain=emc.com;";
    
      var thisdomain=window.location.hostname;
      if (thisdomain =="www.emc.com") {
        domain="emc.com";
      }
        //Old Code
      /*document.cookie = "LASTEMCDOMAIN=" + thisdomain + "; expires=" + date.toGMTString() + "; path=/; domain=emc.com;";*/
        //New code from Tom C for the new URL change
        //Tom send a new code so the next line is replaced
        //document.cookie = "LASTEMCDOMAIN=" + subDomain + ".emc.com; expires=" + date.toGMTString() + "; path=/;";
        //New code START
        if (window.location.hostname.indexOf('test-')>=0) {
         document.cookie = "LASTEMCDOMAIN=test-a-" + (fwDomain=='www.emc.com'?'emc.com':fwDomain) + "; expires=" + date.toGMTString() + "; path=/; domain=emc.com;";
        } else if (window.location.hostname.indexOf('dev-')>=0) {
         document.cookie = "LASTEMCDOMAIN=dev-a-" + (fwDomain=='www.emc.com'?'emc.com':fwDomain) + "; expires=" + date.toGMTString() + "; path=/; domain=emc.com;";
        } else {
         document.cookie = "LASTEMCDOMAIN=" + (fwDomain=='www.emc.com'?'emc.com':fwDomain) + "; expires=" + date.toGMTString() + "; path=/; domain=emc.com;";
        }

        //New code ENDS

    }

          // Leave Support search hidden by CSS unless authenticated (cookie)
      if (!(readCookie('SSZSESSION')===null)) {
           $j('#supportSearchWrapper,#supportAdvancedLink').css('display','block');
      }


          // Support search
          $j('#supportSearchForm img').bind('click',function(ev) {
               searchSubmitSupport(document.getElementById('supportSearchString').value,true);
               ev.preventDefault();
          });
          $j('#supportSearchString').bind('keypress',function(ev) {
               if (ev.which == 13) {
                    searchSubmitSupport(document.getElementById('supportSearchString').value);
                    ev.preventDefault();
               }
          });

          // ECN search
          $j('#searchFormECN img, #searchFormECN .searchIcon').bind('click',function(ev) {
               searchSubmitECN(document.getElementById('searchStringECN').value,true);
               ev.preventDefault();
          });
          $j('#searchStringECN').bind('keypress',function(ev) {
               if (ev.which == 13) {
                    searchSubmitECN(document.getElementById('searchStringECN').value);
                    ev.preventDefault();
               }
          });


     }

/****search code placed here before****/

     // highlight "active" section
     if ($j('#global-nav-section-highlight-data').length>0) {
          $j('#'+$j('#global-nav-section-highlight-data').attr('data-section')+'MenuButton').addClass('current').siblings('a').removeClass('current');
     } else {
          // will match deepest path possible from comma-separated list found in "sections" attribute
          // all paths are root-relative
          // if two paths are equal depth, it uses the first one matched
          var cPath=window.location.href;
          if (cPath.indexOf('//community.emc.com/')>=0) {
               //they're doing this on their end
          } else if (
               cPath.indexOf('//support.emc.com/')>=0 ||
               cPath.indexOf('//ngdev-ci.isus.emc.com/')>=0 ||
               cPath.indexOf('//ngtest-ci1.emc.com/')>=0
          ) {
               cPath=cPath.slice(cPath.indexOf('//')+1);
          } else {
               cPath=cPath.replace(window.location.protocol+'//'+window.location.host,'');
          }
          matchedPathDepth=0;
          $j('.menuItem').each(function(ix,el) {
              var sections = $j(el).attr('sections');
              if (sections){
                  
               $j(sections.split(',')).each(function(sectionIx,sectionName) {
                    if (cPath.slice(0,sectionName.length)==sectionName) {
                         thisPathDepth=sectionName.split('/').length-2;
                         if (thisPathDepth>matchedPathDepth) {
                              $j(el).addClass('current').siblings('a').removeClass('current');
                              matchedPathDepth=thisPathDepth;
                         }
                    }
               });
               
              }
          });

     }
//adding main menu
/*var matchURL= function (){
	var pathname = window.location.href.split("/")[3];
	//New search terms can be add
	var value = /(jp|kr|ru|ua|cn|tw)/g;
	var search = pathname.match(value);
	if (search) return true; else return false;
}

if ( !matchURL() ){
    Cufon.replace('#header #menu .menuItem span', { fontFamily: 'Meta' });
}
*/    
    
    
     // dropdown tabs "last" styling
     $j('.dropDownTabs').each(function(ix,el) {
	$j(el).find('.dropDownTab').last().addClass('last');
     });

     // Cufon
     if ($j('body').hasClass('no-canvas')) {
	  Cufon.replace('.cufon');
     } else {
	  Cufon.replace('#dropDownsInner .cufon');
     }
     //Cufon.replace('#communitiesDropdown .dropdownRightPromo h6', {fontSize: '20px'});

     // icon rollovers
     // temporary fix for Support-MySupport icon
     $j('#globalNavIconMySupport').css('background-position','0px -4418px');
     $j('#dropDowns ul.iconList li.iconListItem,#dropDowns .carouselTray div.iconListItem').bind('mouseenter mouseleave',function(ev) {
          // reset icons
          $j('#dropDowns .iconListItem').removeClass('iconListItem-over');
          $j('#dropDowns .dropdownIconCssSprite').each(function(ix,el) {
               var temp='';
               if (typeof($j(el).css('background-position'))=='undefined') {
                    temp=$j(el).css('background-position-x')+' '+$j(el).css('background-position-y');
               } else {
                    temp=$j(el).css('background-position');
               }
               temp=temp.split(' ');
               temp[0]='0px';
               temp=temp.join(' ');
               $j(el).css('background-position',temp);
               $j('.simulatedA.hover').removeClass('hover');
          });
          var evEl=$j(ev.target).closest('.iconListItem');
          var temp='';
          if (typeof(evEl.find('.dropdownIconCssSprite').css('background-position'))=='undefined') {
               temp=evEl.find('.dropdownIconCssSprite').css('background-position-x')+' '+evEl.find('.dropdownIconCssSprite').css('background-position-y');
          } else {
               temp=evEl.find('.dropdownIconCssSprite').css('background-position');
          }
          temp=temp.split(' ');
          if (ev.type=='mouseenter') {
               temp[0]='-74px';
               evEl.addClass('iconListItem-over');
          } else {
               temp[0]='0px';
               evEl.removeClass('iconListItem-over');               
          }
          temp=temp.join(' ');
          evEl.find('.dropdownIconCssSprite').css('background-position',temp);
     });
     $j('#dropDowns ul.iconList li.iconListItem,#dropDowns .carouselTray div.iconListItem').bind('click',function(ev) {
          // reset icons
          $j('#dropDowns .iconListItem').removeClass('iconListItem-over');
          $j('#dropDowns .dropdownIconCssSprite').each(function(ix,el) {
               var temp='';
               if (typeof($j(el).css('background-position'))=='undefined') {
                    temp=$j(el).css('background-position-x')+' '+$j(el).css('background-position-y');
               } else {
                    temp=$j(el).css('background-position');
               }
               temp=temp.split(' ');
               temp[0]='0px';
               temp=temp.join(' ');
               $j(el).css('background-position',temp);
          });
          $j('.simulatedA.hover').removeClass('hover');
     });
     
}

$j(function(){

     // Variables used for correct calculation of the viewports width + browser's scrollbar.
          var initialWidth   = $j(window).width() + scrollbarWidthCalc();
          var rootElement    = $j('body');

     // search fields default text
     $j('#header .searchString').attr('defaultvalue',''); // CHANGE JULY 2014: no longer showing a default value
     $j('.searchString').each(function(ix,el) {
          var isHeaderSearch = $j(el).parents("#header").length > 0;

          $j(el).val($j(el).attr('defaultvalue'));
          
          $j(el).bind('focus',function(){
               var isHeaderNavOpen = $j("body").hasClass("nav_opened");

               if ($j(el).val()==$j(el).attr('defaultvalue')) {
                    $j(el).val('');
               } else {
                    $j(el).select();
               }
               if(isHeaderSearch){
                   $j(el).addClass('userValue');
                   //$j(".touch #headerWrap").css({position:'relative'});
                   positionSideNavOverride();
               }
               if(!isHeaderNavOpen){
                  $j(".touch .medium .tablet_nav").css("display", "none");
                  $j(".touch .medium .inboundBar").css("display", "none");
               }
          });

          $j(el).bind('blur',function(){
               var isHeaderNavOpen = $j("body").hasClass("nav_opened");

               if ($j(el).val()=='') {
                    $j(el).val($j(el).attr('defaultvalue'));
                    $j(el).removeClass('userValue');
               }
               if(isHeaderSearch){
                   //$j(".touch #headerWrap").css({position:'relative'});//I've changed fixed to relative because it was causing issues in Ipad *Pablo Ascencao
                   positionSideNavOverride();
               }
               if(!isHeaderNavOpen){
                   $j(".touch .medium .tablet_nav").css("display", "");
                   $j(".touch .medium .inboundBar").css("display", "");
               }
          });

     });

    checkSize(initialWidth);    

    //initialize headerSearch
    headerSearch.init();
});

function positionSideNavOverride(){
    var isTouch = $j("html").hasClass("touch"),
        isMedium = $j("body").hasClass("medium"),
        bodyPosLeft = parseInt($j("body").css("left"), 10),
        $headerWrap = $j(".touch #headerWrap"),
        headerWrapPosLeft = parseInt($j("#headerWrap").css("left"), 10),
        sideNavPosLeft = bodyPosLeft - headerWrapPosLeft,
        overrideApplied = ($headerWrap.css("position") === "absolute" && headerWrapPosLeft === 0) || ($headerWrap.css("position") === "fixed" && headerWrapPosLeft < 0 )
    
    if(isTouch && !overrideApplied){
      $headerWrap.css({left: sideNavPosLeft});     
    }    
}

emcghf.dropdowns={};
emcghf.dropdowns.oneTimeInitDone=false;
emcghf.dropdowns.oneTimeInit=function() {
     if (!emcghf.dropdowns.oneTimeInitDone) {
          emcghf.dropdowns.oneTimeInitDone=true;
          $j('.dropDownTabs').each(function(ix0,el0) {
               $j(el0).find('.dropDownTab').each(function(ix,el) {
                    $j(el).attr('ix',ix);
                    $j(el).click(function(ev) {
                         var evEl=$j(ev.target).closest('.dropDownTab');
                         var tgEl=$j(evEl).closest('.dropDownTabs').siblings('.dropDownTabBodies').find('.dropDownTabBody').eq($j(el).attr('ix'));
                         $j(evEl).addClass('on');
                         $j(evEl).siblings('.dropDownTab').removeClass('on');
                         $j(tgEl).show();
                         currentDD=Number($j(evEl).closest('.dropdownItem').attr('ix'));
                         $j(tgEl).siblings('.dropDownTabBody').hide();
                         updateDropdownHeight(); /*C*/
                    });
                    $j(el).closest('.dropDownTabs').siblings('.dropDownTabBodies').find('.dropDownTabBody').eq(0).show();
                    $j(el).closest('.dropDownTabs').siblings('.dropDownTabBodies').find('.dropDownTabBody').eq(0).siblings('.dropDownTabBody').hide();
               });
          });
     }
};


ddazLoaded=false;
function updateDropdownHeight() { /*C*/
     emcghf.dropdowns.oneTimeInit();
     $j('#dropDowns .dropdownItem').css('height','auto');
     $j('#dropDowns .dropdownItem').eq(currentDD).css('display','block').siblings('.dropdownItem').css('display','none');
     var temp=getCurrentDropdownHeight();
     if (temp<100) {
          //trace(currentDD,temp);
          setTimeout(updateDropdownHeight,10);
     } else {
          $j('#dropDowns,#dropDownsInner').clearQueue().stop().animate({
               height: temp+'px'
          },ddAnimTime);
     }
     if (currentDD==0 && !ddazLoaded) {
          // load Products A-Z
          ddazLoaded=true;
          $j.getScript('//'+dotcomDomain+'/R1/assets/js/common/dropdown-az.js');
     }
}
function getCurrentDropdownHeight() { /*C*/
     // normalize col heights
     $j('#dropDowns .dropdownItem').eq(currentDD).find('.dropDownCol').css('height','auto');
     var max=0;
     $j('#dropDowns .dropdownItem').eq(currentDD).find('.dropDownCol').each(function(ix,el) {
          max=Math.max(max,$j(el).height());
     });
     $j('#dropDowns .dropdownItem').eq(currentDD).find('.dropDownCol').height(max);
     return Math.min(parseInt($j('#dropDowns').css('max-height')),$j('#dropDowns .dropdownItem').eq(currentDD).outerHeight());
}

//function openDropdowns() {
     //if ($j('#dropDowns').length && !$j('body').hasClass('isCollapsed') && $j('#dropDowns').css('display')=='block') {
          //updateDropdownHeight(); /*C*/
     //}
//}


function startCloseDropdowns() {
      if ($j('#dropDowns').length && !$j('body').hasClass('isCollapsed')) {
         //alert('inside: startCloseDropdowns()');
           clearTimeout(ddOpenTimeout);
           ddOpenTimeout=setTimeout(closeDropdowns,ddAnimTime);
      }
}

function closeDropdowns(skip) {
    if ($j('#dropDowns').length && !$j('body').hasClass('isCollapsed')) {
       //alert('inside closeDropdowns()');
           skip=false;
           $j(menuItems).each(function(ix,el) {
                //if (skip!=ix) {
                     $j(menuItems[ix]).removeClass('on');
                //}
           });
           //$j('#dropDownIndicator div img').clearQueue().stop().animate({
           //     top: '-10px'
           //},ddAnimTime);
           $j('#dropDownIndicator div img,#dropDownIndicator div div').css({
                 top: '-10px'
           });
           $j('#dropDowns').clearQueue().stop().animate({
                height: '0px'
           }, ddAnimTime);

           /*$j('#header, #headerWrap').clearQueue().stop().animate({
                height: $j('#headerTop').height()+'px'
           }, ddAnimTime);*/

           ddIsOpen = false;
      }
}

function searchSubmit(searchString,isClick) {
    if (searchString=='' || searchString==$j('#searchString').attr('defaultvalue')) {
         return false;
    } else {
         if (isClick) {
              $j('#globalSearchForm').submit();
       return false;
         } else {
              return true;
         }
    }
}
function searchSubmitSupport(searchString,isClick) {
    if (searchString=='' || searchString==$j('#supportSearchString').attr('defaultvalue')) {
         return false;
    } else {
         if (isClick) {
              window.open('https://support.emc.com/search/#text='+$j('#supportSearchString').val());
       return false;
        } else {
              return true;
         }
    }
}

function searchSubmitECN(searchString,isClick) {
     if (searchString=='' || searchString==$j('#searchStringECN').attr('defaultvalue')) {
          return false;
     } else {
          //if (isClick) {
               window.open($j('#searchFormECN').attr('action')+$j('#searchStringECN').val());
       return false;
         //} else {
               //return true;
          //}
     }
}

if (typeof(mainNavTracking)=='undefined') {
     mainNavTracking=function(data) {
  trace('MAIN NAV TRACKING:');
  trace(data);
     }
}
/* NOTE ABOUT TIMEOUTS BELOW -- These are necessary because of the javascript:void(0); HREF attributes.
   For some reason in Chrome and Safari, esp. on Macs, this caused the window.location.href calls below
   to fail silently. Activating on a delay fixes this, but some systems need longer delays than others.
   If it works immediately, great. If not it tries after 1/4 second, if that fails it tries again after 1/2.
*/
function activateSimulatedA(inURL,newWin) {
     if (inURL!='#') {
  mainNavTracking(inURL);
    if (newWin) {
      window.open(inURL);
    } else {
      window.location.href=inURL;
      setTimeout(function(){window.location.href=inURL;},250);
      setTimeout(function(){window.location.href=inURL;},500);
    }
     }
}

function isTablet() {
    if($j(window).width() > 980 && $j('body').hasClass('emcplus-tablet') && $j('html').hasClass('touch')) {
        return true;
    }
};

/* CHANGE JULY 2014 -- REPLACED ENTIRE ANIMATENAV FUNC WITH NEW ONE PLUS "OPENNAV" AND "CLOSENAV" FUNCTIONS TO MAKE CODE MORE READABLE */
function animateNav(whichSide) {

     if (typeof(whichSide)=='undefined') {
        whichSide='left';
     }

     var body = $j("body");
     var header = $j("#headerWrap");
     var footer = $j("#footerWrapper");
     
     var ibState=$j('#inboundBarResp').css('display');
     var navState=$j('#navigation').css('display');
     
     if (body.hasClass('hasInboundBar')) {
          if (typeof($j('#searchFormWrapper').attr('original-right-pos'))=='undefined') {
               $j('#searchFormWrapper').attr('original-right-pos',$j('#searchFormWrapper').css('right'));
          }
          if (typeof($j('#headerTop .btn.btn-navbar').attr('original-right-pos'))=='undefined') {
               $j('#headerTop .btn.btn-navbar').attr('original-right-pos',$j('#headerTop .btn.btn-navbar').css('right'));
          }
          if (typeof($j('#headerTop .btn.btn-inboundbar').attr('original-right-pos'))=='undefined') {
               $j('#headerTop .btn.btn-inboundbar').attr('original-right-pos',$j('#headerTop .btn.btn-inboundbar').css('right'));
          }
          $j('#headerTop .btn.btn-navbar').css('right',$j('#headerTop .btn.btn-navbar').attr('original-right-pos'));
          $j('#headerTop .btn.btn-inboundbar').css('right',$j('#headerTop .btn.btn-inboundbar').attr('original-right-pos'));
     }
     
     // show for calculating widths
     $j('#inboundBarResp').show();
     $j("#navigation").show();

     var menuWidth;
     var elementToReveal;
     var elementToHide;
     var buttonToHide;
     var buttonToReveal;
     
     if (whichSide=='left') {
          menuWidth = -$j("#menu").width();
          elementToReveal=$j("#navigation");
          elementToHide=$j("#inboundBarResp");
          buttonToHide=$j("#headerTop .btn.btn-inboundbar");
          buttonToReveal=$j("#headerTop .btn.btn-navbar");
     } else {
          menuWidth = -$j("#inboundBarResp .ib-slider-wrapper").width();
          elementToReveal=$j("#inboundBarResp");
          elementToHide=$j("#navigation");
          buttonToHide=$j("#headerTop .btn.btn-navbar");
          buttonToReveal=$j("#headerTop .btn.btn-inboundbar");
     }
     
     // put states back how they were
     $j('#inboundBarResp').css('display',ibState);
     $j("#navigation").css('display',navState);

     var windowWidth = $j(window).width() + scrollbarWidthCalc();
     var windowHeight = $j(window).height();
     var menuOverlay  = $j('#mobileMenuOverlay');
     
     if (windowWidth < mediumSize || isTablet()) {
          if (body.hasClass("nav_opened")) {
               closeNav(menuWidth,elementToReveal,elementToHide,buttonToHide,buttonToReveal);
          } else {
               openNav(menuWidth,elementToReveal,elementToHide,buttonToHide,buttonToReveal);
          }
     } else {
          closeNav(menuWidth,elementToReveal,elementToHide,buttonToHide,buttonToReveal);
     }
     
}

function openNav(menuWidth,elementToReveal,elementToHide,buttonToHide,buttonToReveal) {
     var body = $j("body");
     var header = $j("#headerWrap");
     var footer = $j("#footerWrapper");
     var windowHeight = $j(window).height();
     var menuOverlay  = $j('#mobileMenuOverlay');

     //open navigation
     if (body.hasClass('hasInboundBar')) {
          $j(elementToReveal).show();
          $j(elementToHide).hide();
          $j(buttonToReveal).show().css('right',$j('#headerTop .btn.btn-inboundbar').attr('original-right-pos'));
          $j(buttonToHide).hide();
          $j('#searchFormWrapper').css('right',$j('#headerTop .btn.btn-navbar').attr('original-right-pos'));
     }
     body.css({ position: "absolute", width: "100%", "overflow": "hidden"});/*overflow: "hidden",*/
     body.animate({left: menuWidth },400);
     header.animate({left: menuWidth },400);
     if (body.hasClass("medium") && body.hasClass("docked-footer") || isTablet()) {
          footer.animate({left: menuWidth },400);
     }
     body.addClass('nav_opened');
     menuOverlay.addClass('mobNavOpen');
     if ( body.hasClass("medium") || isTablet() ) {
          $j("#navigation, #inboundBarResp .ib-slider-wrapper").css({ "overflow-y": "auto", "height": windowHeight });
          $j("#navigation_wrapper").css({"overflow-y": "hidden", "height": ""});
     } else if (body.hasClass("small")) {
          $j("#navigation_wrapper, #inboundBarResp .ib-slider-wrapper").css({ "overflow-y": "auto", "height": windowHeight + "px" });
          $j("#navigation").css({"overflow-y": "", "height": ""});
     }
}

function closeNav(menuWidth,elementToReveal,elementToHide,buttonToHide,buttonToReveal) {
     var body = $j("body");
     var header = $j("#headerWrap");
     var footer = $j("#footerWrapper");
     var windowHeight = $j(window).height();
     var menuOverlay  = $j('#mobileMenuOverlay');

     //close navigation
     if (body.hasClass('hasInboundBar')) {
          $j('#headerTop .btn.btn-navbar,#headerTop .btn.btn-inboundbar').show();
          $j('#searchFormWrapper').css('right',$j('#searchFormWrapper').attr('original-right-pos'));
     }
     body.animate({left:"0"},400, function() {
          body.css({overflow: "visible"});
          body.removeClass('nav_opened');
          menuOverlay.removeClass('mobNavOpen');
          footer.css({left:"0"}); /* Move to the left from landscape to portrait @Frank - 01/29 */
          $j("#navigation_wrapper").css({"overflow-y": "", "height": "auto"});
          $j("#navigation, #inboundBarResp .ib-slider-wrapper").css({"overflow-y": "", "height": "auto"});
          $j("#navigation").show();
          $j("#inboundBarResp").hide();
     });
     header.animate({left:"0"},400);
     if (body.hasClass("medium") && body.hasClass("docked-footer") || isTablet()) {
          footer.animate({left:"0"},400);
     }
}

function checkNav(initialWidth){
  var menu = $j("#menu"),
    body = $j("body"),
    windowHeight = $j(window).height(),
    menuWidth = $j("#menu").width(),
    menuOverlay = $j('#mobileMenuOverlay');
          navMobileHeight = $j("#navigation").height() + 50;

  /* THIS WILL ADD A CLASS TO THE NAVIGATION WRAPPER DEPENDING ON THE WINDOWS SIZE -- THIS IS USE TO CLOSE THE NAV WHEN THE WINDOW REACH A BREACK POINT */
  if (!$j('#navigation_wrapper').hasClass("smallNav") && !$j('#navigation_wrapper').hasClass("mediumNav") && !$j('#navigation_wrapper').hasClass("largeNav")) {
    if (initialWidth >= mediumSize) {
      $j('#navigation_wrapper').addClass('largeNav');
    } else if (initialWidth < mediumSize && initialWidth > smallSize) {
      $j('#navigation_wrapper').addClass('mediumNav');
    } else if (initialWidth <= smallSize) {
      $j('#navigation_wrapper').addClass('smallNav');

    }
  }
  if (initialWidth >= mediumSize) {
    /* THIS HAPPEND IN LARGE SIZE */
    if (!$j('#navigation_wrapper').hasClass("largeNav")) {
      $j('#navigation_wrapper').removeClass("smallNav").removeClass('mediumNav').addClass('largeNav');
    }
    $j("#navigation_wrapper").css({"overflow-y": "hidden", "height": ""});
    $j("#navigation").css({"overflow-y": "hidden", "height": ""});
    // Fix for left pushed body when resizing from mobile to desktop with the menu opened.
    if (body.hasClass('nav_opened')) {
         body.css({left : 0});
    };
  } else if (initialWidth < mediumSize && initialWidth > smallSize) {
    /* THIS HAPPEND IN MEDIUM SIZE */
    $j("#navigation").css({ "overflow-y": "scroll", "height": windowHeight });
    $j("#navigation_wrapper").css({"overflow-y": "hidden", "height": ""});
    if (body.hasClass('nav_opened')) {
      body.css({left: menuWidth+'px'})
      if ($j('#navigation_wrapper').hasClass("smallNav") || $j('#navigation_wrapper').hasClass("largeNav") ){
        animateNav();
        $j('#navigation_wrapper').removeClass("smallNav").removeClass("largeNav").addClass('mediumNav');
      }
    }
  } else if (initialWidth <= smallSize) {
    /* THIS HAPPEND IN SMALL SIZE */
    $j("#navigation_wrapper").css({ "overflow-y": "scroll", "height": windowHeight + "px"  });
    $j("#navigation").css({"overflow-y": "hidden", "height": ""});
    if (body.hasClass('nav_opened')) {
      if (!$j('#navigation_wrapper').hasClass("smallNav")){
        animateNav();
        $j('#navigation_wrapper').removeClass("largeNav").removeClass("mediumNav").addClass('smallNav');
      }
    }
  }
  else{
    //close navigation
    $j("#navigation_wrapper").css({"overflow-y": "hidden", "height": ""});
    $j("#navigation").css({"overflow-y": "hidden", "height": ""});
    //console.log('x');
    body.css({position: "relative", width: "100%", left: 0});/*overflow: "scroll", */
        body.removeClass('nav_opened');
    menuOverlay.removeClass('mobNavOpen');
  }
}




/* UNIVERSAL CAROUSELS */

jQuery.fn.outerHTML = function(){
    // IE, Chrome & Safari will comply with the non-standard outerHTML, all others (FF) will have a fall-back for cloning
    return (!this.length) ? this : (this[0].outerHTML || (
      function(el){
          var div = document.createElement('div');
          div.appendChild(el.cloneNode(true));
          var contents = div.innerHTML;
          div = null;
          return contents;
    })(this[0]));
}

/* SWIPEVIEW 0.12 FOR IOS VERSION */
var SwipeView=function(){var f="ontouchstart"in window,g="onorientationchange"in window?"orientationchange":"resize",h=f?"touchstart":"mousedown",i=f?"touchmove":"mousemove",j=f?"touchend":"mouseup",l=f?"touchcancel":"mouseup",k=function(a,c){var b,d,e;this.wrapper="string"==typeof a?document.querySelector(a):a;this.options={text:null,numberOfPages:3,snapThreshold:null,hastyPageFlip:!1,loop:!0};for(b in c)this.options[b]=c[b];this.wrapper.style.overflow="hidden";this.wrapper.style.position="relative"; this.masterPages=[];d=document.createElement("div");d.id="swipeview-slider";d.style.cssText="position:relative;top:0;height:100%;width:100%;-webkit-transition-duration:0;-webkit-transform:translate3d(0,0,0);-webkit-transition-timing-function:ease-out";this.wrapper.appendChild(d);this.slider=d;this.refreshSize();for(b=-1;2>b;b++)d=document.createElement("div"),d.id="swipeview-masterpage-"+(b+1),d.style.cssText="-webkit-transform:translateZ(0);position:absolute;top:0;height:100%;width:100%;left:"+100* b+"%",d.dataset||(d.dataset={}),e=-1==b?this.options.numberOfPages-1:b,d.dataset.pageIndex=e,d.dataset.upcomingPageIndex=e,!this.options.loop&&-1==b&&(d.style.visibility="hidden"),this.slider.appendChild(d),this.masterPages.push(d);b=this.masterPages[1].className;this.masterPages[1].className=!b?"swipeview-active":b+" swipeview-active";window.addEventListener(g,this,!1);this.wrapper.addEventListener(h,this,!1);this.wrapper.addEventListener(i,this,!1);this.wrapper.addEventListener(j,this,!1);this.slider.addEventListener("webkitTransitionEnd", this,!1)};k.prototype={currentMasterPage:1,x:0,page:0,pageIndex:0,customEvents:[],onFlip:function(a){this.wrapper.addEventListener("swipeview-flip",a,!1);this.customEvents.push(["flip",a])},onMoveOut:function(a){this.wrapper.addEventListener("swipeview-moveout",a,!1);this.customEvents.push(["moveout",a])},onMoveIn:function(a){this.wrapper.addEventListener("swipeview-movein",a,!1);this.customEvents.push(["movein",a])},onTouchStart:function(a){this.wrapper.addEventListener("swipeview-touchstart",a, !1);this.customEvents.push(["touchstart",a])},destroy:function(){for(;this.customEvents.length;)this.wrapper.removeEventListener("swipeview-"+this.customEvents[0][0],this.customEvents[0][1],!1),this.customEvents.shift();window.removeEventListener(g,this,!1);this.wrapper.removeEventListener(h,this,!1);this.wrapper.removeEventListener(i,this,!1);this.wrapper.removeEventListener(j,this,!1);this.slider.removeEventListener("webkitTransitionEnd",this,!1)},refreshSize:function(){this.wrapperWidth=this.wrapper.clientWidth; this.wrapperHeight=this.wrapper.clientHeight;this.pageWidth=this.wrapperWidth;this.maxX=-this.options.numberOfPages*this.pageWidth+this.wrapperWidth;this.snapThreshold=null===this.options.snapThreshold?Math.round(0.15*this.pageWidth):/%/.test(this.options.snapThreshold)?Math.round(this.pageWidth*this.options.snapThreshold.replace("%","")/100):this.options.snapThreshold},updatePageCount:function(a){this.options.numberOfPages=a;this.maxX=-this.options.numberOfPages*this.pageWidth+this.wrapperWidth}, goToPage:function(a){var c;this.masterPages[this.currentMasterPage].className=this.masterPages[this.currentMasterPage].className.replace(/(^|\s)swipeview-active(\s|$)/,"");for(c=0;3>c;c++)className=this.masterPages[c].className,/(^|\s)swipeview-loading(\s|$)/.test(className)||(this.masterPages[c].className=!className?"swipeview-loading":className+" swipeview-loading");this.pageIndex=this.page=a=0>a?0:a>this.options.numberOfPages-1?this.options.numberOfPages-1:a;this.slider.style.webkitTransitionDuration= "0";this.__pos(-a*this.pageWidth);this.currentMasterPage=this.page+1-3*Math.floor((this.page+1)/3);this.masterPages[this.currentMasterPage].className+=" swipeview-active";0==this.currentMasterPage?(this.masterPages[2].style.left=100*this.page-100+"%",this.masterPages[0].style.left=100*this.page+"%",this.masterPages[1].style.left=100*this.page+100+"%",this.masterPages[2].dataset.upcomingPageIndex=0===this.page?this.options.numberOfPages-1:this.page-1,this.masterPages[0].dataset.upcomingPageIndex=this.page, this.masterPages[1].dataset.upcomingPageIndex=this.page==this.options.numberOfPages-1?0:this.page+1):1==this.currentMasterPage?(this.masterPages[0].style.left=100*this.page-100+"%",this.masterPages[1].style.left=100*this.page+"%",this.masterPages[2].style.left=100*this.page+100+"%",this.masterPages[0].dataset.upcomingPageIndex=0===this.page?this.options.numberOfPages-1:this.page-1,this.masterPages[1].dataset.upcomingPageIndex=this.page,this.masterPages[2].dataset.upcomingPageIndex=this.page==this.options.numberOfPages- 1?0:this.page+1):(this.masterPages[1].style.left=100*this.page-100+"%",this.masterPages[2].style.left=100*this.page+"%",this.masterPages[0].style.left=100*this.page+100+"%",this.masterPages[1].dataset.upcomingPageIndex=0===this.page?this.options.numberOfPages-1:this.page-1,this.masterPages[2].dataset.upcomingPageIndex=this.page,this.masterPages[0].dataset.upcomingPageIndex=this.page==this.options.numberOfPages-1?0:this.page+1);this.__flip()},next:function(){if(this.options.loop||this.x!=this.maxX)this.directionX= -1,this.x-=1,this.__checkPosition()},prev:function(){if(this.options.loop||0!==this.x)this.directionX=1,this.x+=1,this.__checkPosition()},handleEvent:function(a){switch(a.type){case h:this.__start(a);break;case i:this.__move(a);break;case l:case j:this.__end(a);break;case g:this.__resize();break;case "webkitTransitionEnd":a.target==this.slider&&!this.options.hastyPageFlip&&this.__flip()}},__pos:function(a){this.x=a;this.slider.style.webkitTransform="translate3d("+a+"px,0,0)"},__resize:function(){this.refreshSize(); this.slider.style.webkitTransitionDuration="0";this.__pos(-this.page*this.pageWidth)},__start:function(a){this.initiated||(a=f?a.touches[0]:a,this.initiated=!0,this.thresholdExceeded=this.moved=!1,this.startX=a.pageX,this.startY=a.pageY,this.pointX=a.pageX,this.pointY=a.pageY,this.directionX=this.stepsY=this.stepsX=0,this.directionLocked=!1,this.slider.style.webkitTransitionDuration="0",this.__event("touchstart"))},__move:function(a){if(this.initiated){var c=f?a.touches[0]:a,b=c.pageX-this.pointX, d=c.pageY-this.pointY,e=this.x+b,g=Math.abs(c.pageX-this.startX);this.moved=!0;this.pointX=c.pageX;this.pointY=c.pageY;this.directionX=0<b?1:0>b?-1:0;this.stepsX+=Math.abs(b);this.stepsY+=Math.abs(d);if(!(10>this.stepsX&&10>this.stepsY))if(!this.directionLocked&&this.stepsY>this.stepsX)this.initiated=!1;else{a.preventDefault();this.directionLocked=!0;if(!this.options.loop&&(0<e||e<this.maxX))e=this.x+b/2;!this.thresholdExceeded&&g>=this.snapThreshold?(this.thresholdExceeded=!0,this.__event("moveout")): this.thresholdExceeded&&g<this.snapThreshold&&(this.thresholdExceeded=!1,this.__event("movein"));this.__pos(e)}}},__end:function(a){if(this.initiated&&(a=Math.abs((f?a.changedTouches[0]:a).pageX-this.startX),this.initiated=!1,this.moved)){if(!this.options.loop&&(0<this.x||this.x<this.maxX))a=0,this.__event("movein");a<this.snapThreshold?(this.slider.style.webkitTransitionDuration=Math.floor(300*a/this.snapThreshold)+"ms",this.__pos(-this.page*this.pageWidth)):this.__checkPosition()}},__checkPosition:function(){var a, c,b;this.masterPages[this.currentMasterPage].className=this.masterPages[this.currentMasterPage].className.replace(/(^|\s)swipeview-active(\s|$)/,"");0<this.directionX?(this.page=-Math.ceil(this.x/this.pageWidth),this.currentMasterPage=this.page+1-3*Math.floor((this.page+1)/3),this.pageIndex=0===this.pageIndex?this.options.numberOfPages-1:this.pageIndex-1,a=this.currentMasterPage-1,a=0>a?2:a,this.masterPages[a].style.left=100*this.page-100+"%",c=this.page-1):(this.page=-Math.floor(this.x/this.pageWidth), this.currentMasterPage=this.page+1-3*Math.floor((this.page+1)/3),this.pageIndex=this.pageIndex==this.options.numberOfPages-1?0:this.pageIndex+1,a=this.currentMasterPage+1,a=2<a?0:a,this.masterPages[a].style.left=100*this.page+100+"%",c=this.page+1);b=this.masterPages[this.currentMasterPage].className;/(^|\s)swipeview-active(\s|$)/.test(b)||(this.masterPages[this.currentMasterPage].className=!b?"swipeview-active":b+" swipeview-active");b=this.masterPages[a].className;/(^|\s)swipeview-loading(\s|$)/.test(b)|| (this.masterPages[a].className=!b?"swipeview-loading":b+" swipeview-loading");c-=Math.floor(c/this.options.numberOfPages)*this.options.numberOfPages;this.masterPages[a].dataset.upcomingPageIndex=c;newX=-this.page*this.pageWidth;this.slider.style.webkitTransitionDuration=Math.floor(500*Math.abs(this.x-newX)/this.pageWidth)+"ms";this.options.loop||(this.masterPages[a].style.visibility=0===newX||newX==this.maxX?"hidden":"");this.x==newX?this.__flip():(this.__pos(newX),this.options.hastyPageFlip&&this.__flip())}, __flip:function(){this.__event("flip");for(var a=0;3>a;a++)this.masterPages[a].className=this.masterPages[a].className.replace(/(^|\s)swipeview-loading(\s|$)/,""),this.masterPages[a].dataset.pageIndex=this.masterPages[a].dataset.upcomingPageIndex},__event:function(a){var c=document.createEvent("Event");c.initEvent("swipeview-"+a,!0,!0);this.wrapper.dispatchEvent(c)}};return k}();

var universalCarousels={};

universalCarousels.numCarousels=0;

universalCarousels.isIOS=(window.location.href.indexOf('?forceios')>=0 || navigator.userAgent.toLowerCase().search('android')>=0 || navigator.userAgent.toLowerCase().search('iphone')>=0 || navigator.userAgent.toLowerCase().search('ipad')>=0 || navigator.userAgent.toLowerCase().search('ipod')>=0);

universalCarousels.carousels={}; // list of carousels in page by ID (an ID is automatically generated if not present)
universalCarousels.runOnce=false;

universalCarousels.desktop={ // default settings copied to each carousel

    cVel: 0,
    isDragging: false,
    isMoving: false,
    startMouseX: 0,
    cMouseX: 0,
    initialObjX: 0,
    lastObjX: 0,

    moveTimer: false,

    snapTo: true,
    cSnap: 1,
    targetX: 0,

    endReturnSpeed: 0.65, // 0-1, lower is faster
    decelSpeed: 0.95, // 0-1, lower is faster
    snapSpeed: 0.1, // 0-1, lower is SLOWER

    swipeLength: 200, //ms
    isSwipe: false,
    swipeCounter: 0,

    cTab: 0,
    numberOfPages: 0

};


// FOLLOWING VARIABLES ARE SET IN INIT AND START FUNCTIONS PER CAROUSEL

// carousels[i].id=string
// carousels[i].el=parent EL
// carousels[i].itemsPerPage=parent EL attr itemsPerPage
// carousels[i].numPanels=#
// carousels[i].items=[els]
// carousels[i].ios={} SwipeView instance and other IOS-specific settings
// carousels[i].mask=HTML EL
// carousels[i].tray=HTML EL
// carousels[i].controls=HTML EL
// carousels[i].controlType=parent EL attr controlType
// carousels[i].random=parent EL attr random

/* AUTO-INIT FOR LANDING PAGE CAROUSELS, AUTO START */

$j(document).ready(function() {
//    if ($j('.mainFeature.carousel').length) {
//	universalCarousels.init();
//    }
});

universalCarousels.autoStartAll=false;

universalCarousels.startAll=function() {
    for (c in universalCarousels.carousels) {
        universalCarousels.start(universalCarousels.carousels[c].id);
    }
};

universalCarousels.hasInitted=false;

universalCarousels.init=function(el) {

    // if passed a string, get by ID
    if (typeof(el)=='string') { el=$j('#'+el)[0]; }
    
    if (typeof(el)=='undefined') {
	trace('ERROR: Attempting to initialize non-existent carousel!');
    } else {

	// unwrap jQuery object if necessary
	if (el[0]!=undefined) { el=el[0]; }
	
	// must be visible to init properly, save state and restore after initting (including ancestors)
	wasVisible=$j(el).css('display');
	$j(el).css('display','block');
          var parentElsWithDisplayNone=[];
          $j(el).parents().each(function(ix,el1) {
               if ($j(el1).css('display')=='none') {
                    parentElsWithDisplayNone.push(el1);
                    $j(el1).css('display','block');
               }
          });
    
	universalCarousels.numCarousels++;
    
	// force carousel to have an ID for identification in list
	if ($j(el).attr('id')=='') {
	    $j(el).attr('id','carousel-'+universalCarousels.numCarousels);
	}
	
	universalCarousels.carousels[$j(el).attr('id')]={};
	var thisCarousel=universalCarousels.carousels[el.id];
	thisCarousel.config=false;
	thisCarousel.id=el.id;
	thisCarousel.el=el;
	thisCarousel.itemsPerPage=Number(($j(el).attr('itemsPerPage')==undefined)?1:$j(el).attr('itemsPerPage'));
	thisCarousel.items=$j([]);
	thisCarousel.mask=$j(el).find('.carouselMask')[0];
	if (thisCarousel.mask==undefined && $j(el).hasClass('carouselMask')) {
	    thisCarousel.mask=$j(el)[0];
	}
	thisCarousel.tray=$j(el).find('.carouselTray')[0];
	thisCarousel.controls=$j(el).find('.carouselControls')[0];
	thisCarousel.controlType=($j(el).attr('controlType')==undefined)?'individual':$j(el).attr('controlType');
	thisCarousel.random=($j(el).attr('random')==undefined)?0:((String($j(el).attr('random'))=='true')?1:$j(el).attr('random'));
	$j(el).find('.carouselMask').css({
	    position: 'relative',
	    overflow: 'hidden'
	});
	$j(el).find('.carouselTray').css({
	    position: 'absolute'
	});
    
	$j(el).css('display',wasVisible);
        for (var i=0;i<parentElsWithDisplayNone.length;i++) {
          $j(parentElsWithDisplayNone[i]).css('display','none');
        }

    }
    
}

universalCarousels.initAll=function() {
    if (!universalCarousels.hasInitted) {
	universalCarousels.hasInitted=true;
	$j('.universalCarousel').each(function(ix,el) {
	    universalCarousels.init(el);
	});

	if (universalCarousels.autoStartAll) {
	    //universalCarousels.startAll();
	}

    }

};

universalCarousels.push=function(id,item) {
    if (typeof(item.eq)=='function') {
	$j(item).each(function(ix,el){
	    universalCarousels.carousels[id].items.push(item[ix]);
	});
    } else {
        universalCarousels.carousels[id].items.push(item);
    }
};

universalCarousels.start=function(id) {

    thisCarousel=universalCarousels.carousels[id];

    if (typeof(thisCarousel)=='undefined') {
	trace('ERROR: Attempting to start non-existent carousel "'+id+'"!');
    } else {
    
	// must be visible to init properly, save state and restore after initting (including ancestors)
	wasVisible=$j('#'+id).css('display');
	$j('#'+id).css('display','block');
          var parentElsWithDisplayNone=[];
          $j('#'+id).parents().each(function(ix,el1) {
               if ($j(el1).css('display')=='none') {
                    parentElsWithDisplayNone.push(el1);
                    $j(el1).css('display','block');
               }
          });

	thisCarousel.config={ numberOfPages: 0 };
    
	// auto-fill with .item or .panel if no items have been pushed already
	if (thisCarousel.items.length==0) {
	    universalCarousels.push(id,$j(thisCarousel.el).find('.item,.panel'));
	}
    
	thisCarousel.numPanels=Math.ceil(thisCarousel.items.length/thisCarousel.itemsPerPage);
	thisCarousel.numItems=thisCarousel.items.length;
	
	 thisCarousel.random=Math.min(thisCarousel.random,thisCarousel.numItems);
    
	// extend items to full even panels by cloning and emptying last item to even out itemsPerPage counts so last panel is full of items
	// this assumes all items are the same width
    //    for (i=thisCarousel.itemsPerPage-(thisCarousel.numItems%thisCarousel.itemsPerPage);i>0;i--) {
    //	thisCarousel.items.push($j($j(thisCarousel.items)[0]).clone().attr('id','').empty());
    //    }
    
	if (universalCarousels.isIOS) {
    
	    var carouselAncestors=$j('#'+thisCarousel.id).find('.carouselMask').parents();
	    var carouselAncestorsToDisplayNone=[];
	    $j(carouselAncestors).each(function(ancestorIdx,ancestorEl) {
		if ($j(ancestorEl).css('display')=='none') {
		    carouselAncestorsToDisplayNone.push(ancestorEl);
		    $j(ancestorEl).css('display','block');
		}
	    });
    
	    // default config
	    thisCarousel.ios={
		panels: [],
		page: '',
		swipeviewInstance: '',
		mask: ''
	    };
    
	    $j(thisCarousel.items).each(function(ix,el) {
	       if ((ix%thisCarousel.itemsPerPage)==0) {
		    thisCarousel.ios.panels[Math.floor(ix/thisCarousel.itemsPerPage)]='';
		    thisCarousel.config.numberOfPages++;
		}
		thisCarousel.ios.panels[Math.floor(ix/thisCarousel.itemsPerPage)]+=$j(el).outerHTML();
	    });
	    
	    // randomize here if set
	    if (thisCarousel.random>0) {
		tempArr=thisCarousel.ios.panels;
		temp0=[];
		for (i=0;i<thisCarousel.random;i++) {
		    temp0.push(tempArr.shift());
		}
		universalCarousels.shuffleArray(tempArr);
		while (temp0.length) {
		     tempArr.unshift(temp0.pop());
		}
		thisCarousel.ios.panels=tempArr;
	    }
    
	    $j(thisCarousel.mask).empty();
	    maxH=0;
	    cumulativeW=0;
	      singleW=0;
	    $j(thisCarousel.items).each(function(ix,el1) {
		$j(thisCarousel.mask).html(el1);
		maxH=Math.max(maxH,$j(el1).outerHeight());
		  singleW=$j(el1).outerWidth();
		if (ix<thisCarousel.itemsPerPage) {
		    cumulativeW+=$j(el1).outerWidth();
		}
		$j(thisCarousel.mask).empty();
	    });
	    $j(thisCarousel.mask).height(maxH);
	    //$j(thisCarousel.mask).height(maxH+$j(thisCarousel.mask).height());
	    $j(thisCarousel.mask).append('<div/>');
	    thisCarousel.mask=$j(thisCarousel.mask).children('div')[0];
	    $j(thisCarousel.mask).width(singleW*thisCarousel.itemsPerPage).height('100%');
	    //$j(thisCarousel.mask).width(cumulativeW).height(maxH);
	    
	    
	    thisCarousel.ios.swipeviewInstance = new SwipeView(thisCarousel.mask, {
		numberOfPages: thisCarousel.ios.panels.length,
		hastyPageFlip: true,
		loop: false
	    });
    
	    // Load initial data
	    for (i=0; i<3; i++) {
		thisCarousel.ios.page = i==0 ? thisCarousel.ios.panels.length-1 : i-1;
		$j(thisCarousel.ios.swipeviewInstance.masterPages[i]).append(thisCarousel.ios.panels[thisCarousel.ios.page]);
	    }
    
	    if (thisCarousel.numPanels>1) {
    
		  // wire events
		  thisCarousel.ios.swipeviewInstance.onFlip(function(ev) {
		    car=universalCarousels.carousels[$j(ev.target).closest('.universalCarousel').attr('id')];
		    for (i=0; i<3; i++) {
			  upcoming = car.ios.swipeviewInstance.masterPages[i].dataset.upcomingPageIndex;
			  if (upcoming != car.ios.swipeviewInstance.masterPages[i].dataset.pageIndex) {
			    $j(car.ios.swipeviewInstance.masterPages[i]).empty().append(car.ios.panels[upcoming]);
			  }
		    }
		    // update nav ios
		    switch (car.controlType) {
			  case 'nextprev':
			    if (car.ios.swipeviewInstance.page<=0) {
				  $j(car.controls).find('.prev').removeClass('show').addClass('hide');
				  $j(car.controls).find('.next').addClass('show').removeClass('hide');
			    } else if (car.ios.swipeviewInstance.page>=car.ios.swipeviewInstance.options.numberOfPages-1) {
				  $j(car.controls).find('.prev').addClass('show').removeClass('hide');
				  $j(car.controls).find('.next').removeClass('show').addClass('hide');
			    } else {
				  $j(car.controls).find('.prev').addClass('show').removeClass('hide');
				  $j(car.controls).find('.next').addClass('show').removeClass('hide');
			    }
			    break;
			  case 'chiclet':
			  case 'numbered':
			  default:
			    $j(car.controls).find('.box').each(function(ix,el) {
				  if (ix==car.ios.swipeviewInstance.page) {
				    $j(el).removeClass('off').addClass('on');
				  } else {
				    $j(el).removeClass('on').addClass('off');
				  }
			    });
			    break;
		    }
		  });
	    } else {
               $j(thisCarousel.mask).children('div').css({
                    width: cumulativeW+'px',
                    margin: '0px auto'
               })
               $j(thisCarousel.mask).children('div').children('div').css({
                    width: cumulativeW+'px',
                    margin: '0px auto'
               })
            }
    
	    $j(carouselAncestorsToDisplayNone).each(function(ancestorIdx,ancestorEl) {
		$j(ancestorEl).css('display','none');
	    });
		    
	} else {
    
	    // copy default config
	    for (d in universalCarousels.desktop) {
		thisCarousel.config[d]=universalCarousels.desktop[d];
	    }
    
	    // randomize here if set
	    if (thisCarousel.random>0) {
		tempArr=thisCarousel.items.toArray();
		temp0=[];
		for (i=0;i<thisCarousel.random;i++) {
		    temp0.push(tempArr.shift());
		} 
		universalCarousels.shuffleArray(tempArr);
		while (temp0.length) {
		     tempArr.unshift(temp0.pop());
		}
		thisCarousel.items=$j(tempArr);
	    }
    
	    // reposition etc.
	    maxH=0;
	    cumulativeW=0;
	    lastMR=0;
	    $j(thisCarousel.items).each(function(ix,el) {
		if (ix%thisCarousel.itemsPerPage==0) {
		    $j('#'+id).find('.carouselTray').append($j(el).addClass('carouselPanel'));
		    thisCarousel.config.numberOfPages++;
		} else {
		    $j('#'+id).find('.carouselTray').append(el);
		}
		maxH=Math.max(maxH,$j(el).outerHeight());
		lastMR=parseInt($j(el).css('marginRight'));
		//cumulativeW+=$j(el).outerWidth()+lastMR; // outerWidth proved unreliable, doing it manually
		cumulativeW+=$j(el).width()+parseInt($j(el).css('paddingRight'))+parseInt($j(el).css('paddingLeft'))+lastMR;
	    });
	    $j(thisCarousel.items).last().css({ marginRight: '0px' });
	    $j(thisCarousel.tray).height(maxH);
	    $j(thisCarousel.mask).height(maxH);
	    $j(thisCarousel.tray).width(cumulativeW-parseInt(lastMR));
    
	    // do actual order shift in HTML
	    if (thisCarousel.random) {
		$j(thisCarousel.items).each(function(ix,el) {
		    $j(thisCarousel.tray).append(el);
		});
	    }
    
	    if (thisCarousel.numPanels>1) {
	    
		universalCarousels.disableSelection(thisCarousel.mask);
		universalCarousels.disableSelection(thisCarousel.tray);
	  
		$j(thisCarousel.mask).bind('mousedown',function(ev){
            if(ev.which==1){
                universalCarousels.desktop.startDrag(ev);
                ev.preventDefault(); // prevent dragging and dropping images
            }
		});
		$j(thisCarousel.mask).bind('mousemove',function(ev) {
		    universalCarousels.desktop.updatePos(ev);
		});
	  
		$j(thisCarousel.tray).find('.item').live('click',function(ev) {
		    ev.preventDefault();
		});
	    }    
	
	}
    
	if (thisCarousel.numPanels>1) {
    
    
	    // set up nav
	    $j(thisCarousel.controls).empty();
	     switch(thisCarousel.controlType) {
		  case 'nextprev':
		    $j(thisCarousel.controls).html('<div class="box prev"><span>&#0171;</span></div><div class="box next"><span>&#0187;</span></div>');
		    $j(thisCarousel.controls).find('.prev').removeClass('show').addClass('hide');
		    $j(thisCarousel.controls).find('.next').addClass('show').removeClass('hide');
		    universalCarousels.disableSelection($j(thisCarousel.controls).find('.prev')[0]);
		    universalCarousels.disableSelection($j(thisCarousel.controls).find('.next')[0]);
		    break;
		  case 'numbered':
		  case 'chiclet':
		  default:
		    for (p=1;p<=thisCarousel.config.numberOfPages;p++) {
			  $j(thisCarousel.controls).append('<div class="box '+thisCarousel.controlType+' off" style="float: left;" page="'+p+'">'+((thisCarousel.controlType=='numbered')?p:'')+'</div>');
		       universalCarousels.disableSelection($j(thisCarousel.controls).find('.box').last()[0]);
		    }
		    $j(thisCarousel.controls).find('.box.'+thisCarousel.controlType).eq(0).removeClass('off').addClass('on');
	    }
	  
	    // one-time setup functions
	    if (!universalCarousels.runOnce) {
		  if (universalCarousels.isIOS) {
		    // nav
		    $j('.carouselControls .prev').live('click',function(ev) {
			  universalCarousels.carousels[$j(ev.target).closest('.universalCarousel').attr('id')].ios.swipeviewInstance.prev();
		    });
		    $j('.carouselControls .next').live('click',function(ev) {
			  universalCarousels.carousels[$j(ev.target).closest('.universalCarousel').attr('id')].ios.swipeviewInstance.next();
		    });
		    setTimeout(function() {
		     $j('.carouselControls .chiclet, .carouselControls .numbered').live('click',function(ev) {
			  var tPage=Number($j(ev.target).attr('page'))-1;
			  var cPage=universalCarousels.carousels[$j(ev.target).closest('.universalCarousel').attr('id')].ios.swipeviewInstance.pageIndex;
			  var diff=tPage-cPage;
			  if (diff>0) {
			     for (i=0;i<diff;i++) {
				  setTimeout(function(){
				     universalCarousels.carousels[$j(ev.target).closest('.universalCarousel').attr('id')].ios.swipeviewInstance.next();
				  },i*500);
			     }
			  } else if (diff<0) {
			     for (i=0;i<Math.abs(diff);i++) {
				  setTimeout(function(){
				     universalCarousels.carousels[$j(ev.target).closest('.universalCarousel').attr('id')].ios.swipeviewInstance.prev();
				  },i*500);
			     }
			  }
			  //trace(tPage+' '+cPage);
			//universalCarousels.carousels[$j(ev.target).closest('.universalCarousel').attr('id')].ios.swipeviewInstance.goToPage(tPage);
		     });
		    },1000);
		  } else {
		    // page-wide events apply to all carousels
		    universalCarousels.desktop.moveTimer=setInterval(universalCarousels.desktop.updateScrollArea,33);
		    $j(document).bind('mouseup',universalCarousels.desktop.stopDrag);
		    // nav
		    $j('.carouselControls .next').live('click',universalCarousels.desktop.clickNext);
		    $j('.carouselControls .prev').live('click',universalCarousels.desktop.clickPrev);
		    $j('.carouselControls .chiclet, .carouselControls .numbered').live('click',universalCarousels.desktop.clickIndividual);
		  }
		  universalCarousels.runOnce=true;
	    }
	  
	    // auto rotate config and start
	    if ($j(thisCarousel.el).attr('delay')>=0) {
		  thisCarousel.config.autoRotateTime=Number($j(thisCarousel.el).attr('delay'));
		  $j(thisCarousel.mask).mouseenter(function() {
		    universalCarousels.stopRotate(id);
		  });
		  $j(thisCarousel.mask).mouseleave(function() {
		    universalCarousels.rotate(id);
		  });
		  $j(thisCarousel.controls).mouseenter(function() {
		    universalCarousels.stopRotate(id);
		  });
		  $j(thisCarousel.controls).mouseleave(function() {
		    universalCarousels.rotate(id);
		  });
		  $j(thisCarousel.mask).bind('touchstart',function() {
		    universalCarousels.stopRotate(id);
		    universalCarousels.resumeRotateAfterInteract(id);
		  });
		  //$j(thisCarousel.mask).bind('touchend',function() {
		  //    universalCarousels.resumeRotateAfterInteract(id);
		  //});
		  universalCarousels.rotate(id);
	    }
    
          $j(thisCarousel).closest('.universalCarousel').addClass('universal-carousel-active');
    
	} else {
          
          $j(thisCarousel.mask).closest('.universalCarousel').addClass('universal-carousel-inactive');

        }
        
    }
	
	$j('#'+id).css('display',wasVisible);
        for (var i=0;i<parentElsWithDisplayNone.length;i++) {
          $j(parentElsWithDisplayNone[i]).css('display','none');
        }

};


/* AUTO ROTATE */

universalCarousels.resumeRotateAfterInteractInt=0;;
universalCarousels.resumeRotateAfterInteract=function(id) {
    universalCarousels.resumeRotateAfterInteractInt=setTimeout(function() {
	    universalCarousels.rotate(id);
    },car.config.autoRotateTime*1000);
};
universalCarousels.rotate=function(id) {
    clearTimeout(universalCarousels.resumeRotateAfterInteractInt);
    car=universalCarousels.getCarouselById(id);
    universalCarousels.stopRotate(id);
    car.config.autoRotateTimeout=setTimeout( function() { universalCarousels.next(id); universalCarousels.rotate(id); }, car.config.autoRotateTime*1000);
};
universalCarousels.stopRotate=function(id) {
    car=universalCarousels.getCarouselById(id);
    clearTimeout(car.config.autoRotateTimeout);
};

universalCarousels.next=function(id) {
    car=universalCarousels.getCarouselById(id);
    if (universalCarousels.isIOS) {
	//car.ios.swipeviewInstance.next();
        var cPage=car.ios.swipeviewInstance.pageIndex;
        if (cPage==car.ios.swipeviewInstance.options.numberOfPages-1) {
            $j('.carouselControls .chiclet').eq(0).click();
        } else {
            $j('.carouselControls .chiclet').eq(cPage+1).click();
        }
    } else {
	universalCarousels.desktop.changePanel(car,car.config.cSnap+1,true);
    }
};


/* UTILITY */

universalCarousels.disableSelection=function(target){
    if (typeof target.onselectstart!="undefined") //IE route
	target.onselectstart=function(){return false}
    else if (typeof target.style.MozUserSelect!="undefined") //Firefox route
	target.style.MozUserSelect="none"
    else //All other route (ie: Opera)
	target.onmousedown=function(){return false}
};

universalCarousels.desktop.mouseX=function(evt) {
    var val;
    if (navigator.userAgent.match(/like Mac OS X/i)) {
	val = evt.originalEvent.touches[0].pageX;
    } else {
	if (!evt) { evt = window.event; }
	if (evt.pageX) {
	    val = evt.pageX;
	} else if (evt.clientX) {
	    val = evt.clientX + (document.documentElement.scrollLeft ? document.documentElement.scrollLeft : document.body.scrollLeft);
	} else {
	    val = 0;
	}
    }
    return val;
};


/* DESKTOP VERSION */

universalCarousels.getCarouselFromEv=function(ev) {
    return universalCarousels.carousels[$j(ev.target).closest('.universalCarousel').attr('id')];
};
universalCarousels.getCarouselById=function(id) {
    return universalCarousels.carousels[id];
};

universalCarousels.desktop.clickIndividual=function(ev) {
    car=universalCarousels.getCarouselFromEv(ev);
    universalCarousels.desktop.changePanel(car,Number($j(ev.target).closest('.box').attr('page')));
};
universalCarousels.desktop.clickNext=function(ev) {
    car=universalCarousels.getCarouselFromEv(ev);
    universalCarousels.desktop.changePanel(car,car.config.cSnap+1);
};
universalCarousels.desktop.clickPrev=function(ev) {
    car=universalCarousels.getCarouselFromEv(ev);
    universalCarousels.desktop.changePanel(car,car.config.cSnap-1);
};

universalCarousels.desktop.changePanel=function(car,ix,wrap) {
    if (wrap==undefined) { wrap=false; }
    car.config.cSnap=ix;
    if (car.config.cSnap<1) { car.config.cSnap=1; }
    if (wrap) {
	if (car.config.cSnap>car.config.numberOfPages) { car.config.cSnap=1; }
    } else {
	if (car.config.cSnap>car.config.numberOfPages) { car.config.cSnap=car.config.numberOfPages; }
    }
    car.config.isMoving=true;
    universalCarousels.desktop.setTargetX(car);
};

universalCarousels.desktop.isntSwipe=function(car) {
    car.config.isSwipe=false;
};

universalCarousels.desktop.getSnapToX=function(car,ix) {
    evEl=$j(car.tray).find('.carouselPanel')[ix-1];
    xPos=$j(evEl).position().left;
    return xPos/$j(car.tray).width();
};

universalCarousels.desktop.setTargetX=function(car) {
    car.config.targetX=Math.floor((universalCarousels.desktop.getSnapToX(car,car.config.cSnap)*-$j(car.tray).width()));
    car.config.targetX=Math.min(car.config.targetX,0);
    car.config.targetX=Math.max(car.config.targetX,-($j(car.tray).width()-$j(car.mask).width()));
};

universalCarousels.desktop.startDrag=function(ev) {

    car=universalCarousels.getCarouselFromEv(ev);

    car.config.isMoving=true;
    car.config.isDragging=true;
    car.config.hasDragged=true;
    car.config.cVel=0;
    car.config.startMouseX = universalCarousels.desktop.mouseX(ev) - car.mask.offsetLeft;
    car.config.cMouseX = car.config.startMouseX;
    car.config.initialObjX=$j(car.tray).position().left;
    car.config.lastObjX=car.config.initialObjX;
    clearTimeout(car.config.swipeCounter);
    car.config.isSwipe=true;
    car.config.swipeCounter=setTimeout(function() { universalCarousels.desktop.isntSwipe(car); },car.config.swipeLength);

};

universalCarousels.desktop.stopDrag=function(ev) {
    for (c in universalCarousels.carousels) {
        car=universalCarousels.carousels[c];
        if (car.config.isDragging) {

	    cW=$j(car.tray).width();
	    minX=($j(car.tray).width()-$j(car.mask).width());
	    if (car.config.isSwipe && $j(ev.target).closest('a,simulatedA').html()!=null && (Math.abs(car.config.startMouseX-car.config.cMouseX)<=10 || car.config.cMouseX=='undefined')) {
                if (!$j(ev.target).closest('a,simulatedA').hasClass('allowJSevents')) {
                    //trace('click simulation in carousel');
                    if ($j(ev.target).closest('a,simulatedA').attr('target')=='_blank') {
                         window.open($j(ev.target).closest('a,simulatedA').attr('href'));
                    } else {
                         window.location=$j(ev.target).closest('a,simulatedA').attr('href');
                    }
                } else {
                    //trace('js event in carousel');
                    //ev.preventDefault();
                    if (clickItemBox) { clickItemBox(ev); }
               }
	    } else {
               ev.preventDefault();
            }
	    clearTimeout(car.config.swipeCounter);
	    if (car.config.snapTo && car.config.isSwipe) {
		car.config.isSwipe=false;
		if (Math.abs(car.config.startMouseX-car.config.cMouseX)>10 && car.config.cMouseX!='undefined') { // prevent swipe on click
		    if (car.config.startMouseX<=car.config.cMouseX) { // right
			car.config.cSnap=Math.max(car.config.cSnap-1,1);
		    } else { //left
			car.config.cSnap=Math.min(car.config.cSnap+1,car.numPanels);
		    }
		    universalCarousels.desktop.setTargetX(car);
		}
	    } else {
		if (car.config.snapTo) {
		    car.config.cVel=0;
		    car.config.targetX=0;
		    centerX=0;
		    leftXperc=(-$j(car.tray).position().left)/$j(car.tray).width();
		    for (i=1;i<car.numPanels;i++) {
			if (leftXperc>universalCarousels.desktop.getSnapToX(car,i)) {
			    car.config.cSnap=i;
			}
		    }
		    if (leftXperc-universalCarousels.desktop.getSnapToX(car,car.config.cSnap)>(universalCarousels.desktop.getSnapToX(car,car.config.cSnap+1)-universalCarousels.desktop.getSnapToX(car,car.config.cSnap))/2) {
			car.config.cSnap++;
		    }
		    universalCarousels.desktop.setTargetX(car);
		} else {
		    if (car.config.cVel>0) {
			car.config.cVel=Math.max(10,Math.min(car.config.cVel,100));
		    } else if (cVel<0) {
			car.config.cVel=Math.min(-10,Math.max(car.config.cVel,-100));
		    }
		}
	    }
	    car.config.isDragging=false;
            setTimeout(function() {
               car.config.hasDragged=false;
            },50)
	}
    }
    //if (ev) { ev.preventDefault(); }
    //return false;
};

universalCarousels.desktop.updatePos=function(ev) {
    for (c in universalCarousels.carousels) {
        car=universalCarousels.carousels[c];
	car.config.cMouseX=universalCarousels.desktop.mouseX(ev) - car.mask.offsetLeft;
	if (car.config.isDragging) {
	    newX=(car.config.initialObjX+car.config.cMouseX-car.config.startMouseX);
	    $j(car.tray).css('left',newX+'px');
	}
    }
};

universalCarousels.desktop.updateScrollArea=function() {

    for (c in universalCarousels.carousels) {
        car=universalCarousels.carousels[c];

	if (car.config!=false && $j(car.mask).width()>0) {
	    cX=$j(car.tray).position().left;
	    if (cX!=car.config.targetX && car.config.isMoving) {
		cW=$j(car.tray).width();
		minX=(cW-$j(car.mask).width());
		if (car.config.isDragging) {
		    car.config.cVel=(cX-car.config.lastObjX);
		    car.config.lastObjX=cX;
		} else {
		    if (car.config.snapTo) {
			if (Math.abs(cX-car.config.targetX)>1) {
			      changeAmt=((car.config.targetX-cX)*car.config.snapSpeed);
			      if (changeAmt<0 && changeAmt>-2) { changeAmt=-2; }
			      if (changeAmt>0 && changeAmt<2) { changeAmt=2; }
			      cX=cX+changeAmt;
			      //$j('#output').append('====================================');			      
			      //$j('#output').append(changeAmt+' '+Math.round(cX)+' '+$j(car.tray).css('left')+'<br/>');
			      $j(car.tray).css('left',Math.round(cX)+'px');
			      //$j('#output').append(changeAmt+' '+Math.round(cX)+' '+$j(car.tray).css('left')+'<br/>');
			} else {
			    cX=car.config.targetX;
			    $j(car.tray).css('left',Math.round(cX)+'px');
			    car.config.isMoving=false;
			}
		    } else { // coast
			if (cX>0) {
			    car.config.cVel=0;
			    cX*=car.config.endReturnSpeed;
			    $j(car.tray).css('left',Math.floor(cX)+'px');
			} else if (cX<-minX) {
			    car.config.cVel=0;
			    cX=-minX+((cX+minX)*car.config.endReturnSpeed);
			    $j(car.tray).css('left',Math.floor(cX)+'px');
			} else {
			    car.config.cVel*=car.config.decelSpeed;
			    if (car.config.cVel<1 && car.config.cVel>-1) { car.config.cVel=0; }
			    if (car.config.cVel!=0) {
				$j(car.tray).css('left',($j(car.tray).position().left+Math.floor(car.config.cVel))+'px');
			    }
			}
		    }
		    if (cX==car.config.targetX) {
			 //trace('================MATCH===== '+cX+' '+car.config.targetX);
			 car.config.isMoving=false;
		    } else {
			 //trace(cX+' '+car.config.targetX);
		    }
		}
		// update nav desktop
		switch (car.controlType) {
		    case 'nextprev':
			if (car.config.cSnap<=1) {
			    $j(car.controls).find('.prev').removeClass('show').addClass('hide');
			    $j(car.controls).find('.next').addClass('show').removeClass('hide');
			} else if (car.config.cSnap>=car.config.numberOfPages) {
			    $j(car.controls).find('.prev').addClass('show').removeClass('hide');
			    $j(car.controls).find('.next').removeClass('show').addClass('hide');
			} else {
			    $j(car.controls).find('.prev').addClass('show').removeClass('hide');
			    $j(car.controls).find('.next').addClass('show').removeClass('hide');
			}
			break;
		    case 'chiclet':
		    case 'numbered':
		    default:
			$j(car.controls).find('.box').each(function(ix,el) {
			    if (ix==car.config.cSnap-1) {
				$j(el).removeClass('off').addClass('on');
			    } else {
				$j(el).removeClass('on').addClass('off');
			    }
			});
			break;
		}
	    }
	}

    }

};



universalCarousels.shuffleArray = function(array) {
    for (var i = array.length - 1; i > 0; i--) {
        var j = Math.floor(Math.random() * (i + 1));
        var temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    return array;
}




function renderModal(selector, html, options) {
  var parent = "body",
      $this = $j(parent).find(selector);

  options = options || {};
  options.width = options.width || 'auto';

  if ($this.length == 0) {
    var selectorArr = selector.split(".");
    var $wrapper = $j('<div class="modal hide fade ' + selectorArr[selectorArr.length-1] + '"></div>').append(html);
    $this = $wrapper.appendTo(parent);
    $this.modal();
  } else {
    $this.html(html).modal("show");
  }

  $this.css({
    width: options.width,
    'margin-left': function () {
      return -($(this).width() / 2);
    }
  });
}

var addMenuItems = function() {
  //Force new items into header
  var countryTxt = $j('#siteSelectButton a').text(),
  menuItem = '<a class="menuItem hp-dd-change-country" href="/utilities/globalsiteselect.jhtml"><img src="/images/homepage/css/hp-dd-globe.png" alt="Globe Icon"> '+countryTxt+' <span>| Change Country</span></a>',
  btnDdMenu = '<a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse"><span class="icon-bar"></span><span class="icon-bar"></span><span class="icon-bar"></span></a>';
  $j('#menu').append(menuItem).addClass('nav').addClass('nav-collapse');
}

//addMenuItems();  commented because an extra link is added and not desired.

var headerCheckSize = function () {
  //$j = jQuery.noConflict();
  $j('#headerWrap, #header').removeClass('show').removeAttr('style');
  if ($j('html').hasClass('legacy')) {
    if ($j('body').hasClass('no-menudropdowns')) {
      initDropdowns();
    } else {
      tryDDtimeout=setTimeout(tryDropdowns,250);
    }
  } else {
    initDropdowns();
  }

  var winSize = $j(window).width();
  // Desktop & Tablet
  if (winSize > '640') {
    //$j('#menu, .hp-search-collapse').removeClass('show').removeAttr('style');
    $j('.hp-search-collapse').removeClass('show').removeAttr('style');
    $j('#menu.show').removeClass('show').animate({left: "-"+menuWidth+"px"},600, function(){ $j('body').css({overflow: "visible"}); });
  }
};

headerCheckSize();

var resizeTimerH;

/*$j(window).resize(function() {
    clearTimeout(resizeTimerH);
    resizeTimerH = setTimeout(headerCheckSize, 100);
});*/

  $j('#mobileMenuOverlay.mobNavOpen').live('click', function(e) {
    if($j('body').hasClass('nav_opened')){
      e.preventDefault();
      animateNav();
    }
  });
  $j('#header .btn-navbar').live('click', function() {
    if(!$j(this).hasClass('hp-search-lnk')){
      animateNav();
    }
  });
  /*$j('#navigation').live('click', function(e) {
    if(!$j('body').hasClass('large')){
      e.preventDefault();
    }
  });*/

     var timeOut,
          currentHeight,
          currentWidth;

     $j(window).resize(function() {
          var  windowHeight   = $j(window).height(),
               windowWidth    = $j(window).width() + scrollbarWidthCalc();
          
          // Close menu if it's opened and orientation changes.
          var closeOnResize = (function() {

            // Snippet to check if element has focus (some pages are using jQuery 1.5). - https://gist.github.com/cowboy/450017
            jQuery.expr[':'].focus = function( elem ) {
              return elem === document.activeElement && ( elem.type || elem.href );
            };

            // Some devices fire resize event when browser's keyboard is shown. Close navigation only if search input isn't focused.
            if($j('body').hasClass('nav_opened') && !$j('.searchString').is(':focus')){
                $j("#navigation_wrapper").css({"overflow-y": "scroll", "height": windowHeight + "px"});
                animateNav();
                $j('html').scrollTop('0');
            }

          }());

          // Preview window size check because IE 8 event resize bug.
          if (currentHeight == undefined || currentHeight != windowHeight || currentWidth == undefined || currentWidth != windowWidth) {

               // Check first page load because IE 8 event resize bug.
               if (browserIsIE8 && isFirstLoad) {
                    isFirstLoad = false;
                    return;
               }


               initialWidth = $j(this).width() + scrollbarWidthCalc();
               clearTimeout(timeOut);
               timeOut = setTimeout(function() {
                    checkNav(initialWidth);
                    checkSize(initialWidth);
               }, 400);

               isFirstLoad = false;
               currentHeight = windowHeight;
               currentWidth = windowWidth;

          };

     });

  $j('body').unbind('click.headerMenu');
  if ($j('#menu.show').length > 0 || $j('.hp-search-collapse.show').length > 0) {
    $j('body').bind('click.headerMenu', function(e) {
      if (!$j(e.target).hasClass('searchString') && !$j(e.target).hasClass('hp-search-collapse')) {
        $j('body.small').unbind('click.headerMenu');
      }
      if (!$j(e.target).hasClass('btn-navbar') && !$j(e.target).hasClass('icon-bar') && !$j(e.target).hasClass('searchString') && !$j(e.target).hasClass('hp-search-collapse')) {
        $j('.hp-search-collapse.show').removeClass('show').animate({left: "-"+menuWidth+"px"},600);
        $j('#menu.show').removeClass('show').animate({left: "-"+menuWidth+"px"},600);
        $j('#headerTop').animate({left: "0"},600);
        $j('#lightboxHide').css({position: "relative"}).animate({left: "0"},600);
      }
    });
  }

// OPEN HEADER LINKS
$j('body.small #headerWrap a.menuItem').live('click', function(e) {
  e.preventDefault();
  window.open($j(this).attr('href'), '_self');
  return false;
});

// OPEN FOOTER LINKS IN NEW WINDOW FOR MOBILE (PHONE)
$j('body.small #footerRightText1st a').live('click', function(e) {
  e.preventDefault();
  window.open($j(this).attr('href'), '_blank');
  return false;
});
//social share button functionality
function footerShareLinksShowHide(divID, check) {
  var shareIcon = $j('#' + divID).closest('.shareIcon');
  if(check == true){
    if(!shareIcon.hasClass("hideShareLink")){
      shareIcon.addClass("hideShareLink")
    }
  }else{
    shareIcon.toggleClass("hideShareLink");
  }
}
/* CHANGE JULY 2014: NEW FOOTER SHARE JS */
$j(window).load(function() {
     $j('#footerBottomShare').click(function(ev) {
          ev.preventDefault();
          if (!$j('#nightShadeContainerContent').find('#footer-social-more-overlay').length) {
              $j('#nightShadeContainerContent').append('<div id="footer-social-more-overlay" class="overlayPage"><div id="footer-social-more-overlay-addthis" class="addthis_toolbox addthis_default_style addthis_32x32_style"><h3>'+$j('#footerBottomShare').text()+'</h3></div></div>');
              for (var i=1;i<=20;i++) {
                  $j('#footer-social-more-overlay-addthis').append('<a class="addthis_button_preferred_'+i+'"></a>');
                  if (i%5==0) {
                      $j('#footer-social-more-overlay-addthis').append('<br/>');
                  }
              }
              $j('#footer-social-more-overlay-addthis').append('<div class="clearBothTight"></div>');
              addthis.toolbox('#footer-social-more-overlay-addthis');
          }
          openOverlay('footer-social-more-overlay');
     });
});
$j(document).ready(function() {
  /*$j('#footer .shareBtn a').live('click', function() {
    footerShareLinksShowHide('footerShareLinks', false);
  });*/
    footerShareLinksShowHide('footerShareLinks', true);
});
//SHOW/HIDE FOOTER EXPANDED STATE
if($j("body").hasClass("docked-footer")){
  $j('#footer #moreLinks').live('click', function(){
    animateFooter("click");
  });

  $j(window).resize(function(){
    animateFooter("resize");
  })
}

function animateFooter(arg){

  var $ftWr = $j('#footerWrapper'),
    $ftEx = $j('#footerExpanded'),
    $header = $j('#headerWrap').height(),
    $footDock = $j('#footerDock').outerHeight(),
    winHeight = $j(window).height(),
    fullHeight = $ftEx.css('height' , '100%').height(),
    isSmall = $j("body").hasClass("small");

  $ftEx.css('height' , '0');

  if(arg == "click"){
    if( $ftWr.hasClass('expanded') ){
      if($ftEx.hasClass('footerSmallHeightOpen')){
        $ftEx.css({
          height : 'auto'
        }).removeClass('footerSmallHeightOpen')
      }
      $ftEx.animate({height:'0'}, 250, function() {
        $ftWr.removeClass('expanded')
        footerShareLinksShowHide('footerShareLinks', true);
      });
      $j('.hide', $ftWr ).hide();
      $j('.show', $ftWr).show();

    }else{
      $ftEx.css('height' , '0');
      $ftWr.addClass('expanded');
      if(winHeight <= fullHeight){
        $ftEx.animate({height: winHeight - $header - $footDock}, 250, function(){ $ftEx.addClass('footerSmallHeightOpen'); });
      }else{
        $ftEx.animate({height: fullHeight}, 250, function(){ $ftEx.css("height", "100%") });
      }
      footerShareLinksShowHide('footerShareLinks', true);
      $j('.hide', $ftWr ).show();
      $j('.show', $ftWr).hide();
    };

  }
  else if (arg == "resize" && $ftWr.hasClass('expanded')){
    if(fullHeight >= winHeight ){
      //console.log("footer resize tablet");
      $ftEx.css({height: winHeight - $header - $footDock});
    }else{
      $ftEx.css("height", "100%");
    }
  }
}




//Inject input type ahead component for dependencies
var EMC = EMC || {};
EMC.Components = EMC.Components || {};
 

EMC.Components.typeAheadPromise = $j.ajax({
  type: "GET",
  url: "/R1/assets/js/components/input-typeahead.js"
});

/**
 * Search input type ahead and submit functionality
 * @type {Object}
 */
var headerSearch = {
  init: function(){
    var that = this;

    this.$keywordsInput = $j("input#searchString");
    this.$searchWrapper = $j("#globalSearchForm");
    
    this.placeholderText = this.$keywordsInput.val();

    //render typeahead to dom
    this.renderTypeaheadContainer();
    this.$typeaheadContainer = $j(".type-ahead", this.$searchWrapper);

    //disable autocomplete for input
    this.$keywordsInput.attr("autocomplete", "off").attr("maxlength", "1600");

    EMC.Components.typeAheadPromise.then( function(){
      //instantiate type ahead for global header search
      that.headerSearchTypeAhead = new EMC.Components.TypeAhead({
        "wrapper": "globalSearchForm",
        "url": "http://"+dotcomDomain+"/enterprisesearch/keywordTypeAhead.htm", 
        "keywordParam": "q", 
        "optionalParams": {"clientId": "uw", "max": 5},
        "responseType": "string",
        "minChar": 3
      });
    })
    

    //listen to events
    this.events();    
  },
  events: function(){
      var that = this;      

      this.$searchWrapper.submit($j.proxy(that.submitSearch, this));

      //searchIcon
      $j(".searchIcon", this.$searchWrapper).click($j.proxy(that.submitSearch, this));
  },
  /**
   * submitSearch: when triggered submit search form
   * @param  {Object} e        event object that triggered the method
   * @param  {Object} eventObj event object that represents the users action
   */
  submitSearch: function(e){    
    var that = this,
        $inputVal = $j.trim(that.$keywordsInput.val()),
        inputValue = $inputVal == this.placeholderText ? "" : $inputVal,
        query = inputValue == "" ? "" : "#search/query:q=" + encodeURIComponent(inputValue) + ";p:cPage=1";
        
        e.preventDefault();
        //redirect to search page
        window.location = "/"+aemLocale+"/search.htm" + query;
  },
  /**
   * Render typeahead container to header
   */
  renderTypeaheadContainer: function(){
    var wrapper = '<div class="type-ahead"></div>';
    $j(wrapper).appendTo(this.$searchWrapper);
  }
};



/*
Ext JS - JavaScript Library
Copyright (c) 2006-2011, Sencha Inc.
All rights reserved.
licensing@sencha.com
*/
//try { console.log(); } catch(e) { console = { log: function(x) {alert(x);} } }
try { console.log(); } catch(e) { console = { log: function(x) {} } }

// this seems to be causing problems in IE. Ext Rulez! :(
if (Ext.isIE) { Ext.enableGarbageCollector = false; }

if (!Ext.EMC) {
	Ext.namespace('Ext.EMC');
}

/**
 * @class Ext.EMC.Modal A modal dialog implementation for HTML fragments.
 * @extends Object
 * @cfg {boolean} closeOnOverlayClick Wether to close the overlay by (true) clicking outside the viewport or by (false) any other means
 * @cfg {object} autoCenter Wether to vertically or horizontally center the overlay (autoCenter.vert=true, autoCenter.horz=true)
 * @cfg {object} viewportOffset How far from the top-left edge does the viewport need to be (in pixels)
 * @cfg {object} overlayOffset How far from the top-left edge does the viewport need to be (in pixels)
 * @cfg {object} classes Names for the classes the modal dialog will use 
 * @cfg {object} buttons Any buttons you may want the modal to add programatically
 * @cfg {string} wrapperId the ID the outermost element will have (minus its ID)
 * @cfg {integer} width the viewport's width in pixels. Auto-calculated if empty
 * @cfg {integer} height the viewport's height in pixels. Auto-calculated if empty
 * @constructor
 * @param {string / object} element The element whose contents will appear in the modal dialog.Can either be a string or a DOMNode
 * @param {object} cfg an object containing the required configuration options for this class
**/
Ext.EMC.ModalsCache = {};

//Ext JS 4.x class definition
Ext.define('Ext.EMC.Modal', {
    extend: 'Ext.util.Observable',
    dom: {
        manip: Ext.core.DomHelper,
        query: Ext.DomQuery.select
    },
    id: null,
    isVisible: false,
    modals : new Array(),
    defaults: {
        width:false, 
        height:false,
        closeOnOverlayClick: true, //false if you want the modal to only be closable through other means
        overlayOffset: {top:0, left:0},
        viewportOffset: {top: 0,left: 0},
        classes: {
            visible:'visible',//an optionally interesing class to further theme the visible modal
            invisible:'hidden',//a class that is applied to hide the modal
            locked:'unscrollable',//a class that is applied to the body to prevent it from scrolling
            outerWrapper:'modal-dialog-overlay',//a class that is applied to the overlay itself
            buttonWrapper:'modal-dialog-buttons',//a class that is applied to the buttons container
            innerWrapper:'modal-dialog-viewport',//a class that is applied to the modal's "viewport"
            contentWrapper: 'modal-dialog-contents'//a class that is applied to the modal's actual content
        },
        buttons: [],
        destroy: false,
        wrapperId:'modal-dialog',
        rootNode : null
    },
    cfg: {},
    constructor: function(element, cfg){
        this.addEvents({
            "modalOpened" : true,
            "modalClosed" : true
        });
        
        this.listeners = cfg.listeners;
        

        var viewportID = this.dom.query('.modal-dialog-contents').length;
        Ext.apply(this.cfg, cfg, this.defaults);
        // call parent
        this.callParent([cfg]);
        
        this.id = parseInt(viewportID);
        this.cfg.elements = {
          toOverlay: Ext.select(element),
          body: Ext.get(document.getElementsByTagName('body')[0])
        };
        
        this.modals[this.id] = new Object();
        this.modals[this.id].width = this.cfg.width;
        this.buildOverlay();
        this.addHooks();
        Ext.EMC.ModalsCache[this.getId()] = this;
    },
  
    toggleGivenOverlay: function(){
        var overlay = this.getAttribute('id');
        if(!!Ext.EMC.ModalsCache[overlay].cfg.closeOnOverlayClick){
            Ext.EMC.ModalsCache[overlay].toggle();
        }
    },
  
    addHooks: function(){
        var wrappers = Ext.get(this.dom.query('.' + this.cfg.classes.outerWrapper)),
        contents = Ext.get(this.dom.query('.' + this.cfg.classes.innerWrapper)),
        me = this;
        wrappers.each(function(element){
            element.on('click', me.toggleGivenOverlay);
        });
        contents.on('click',function(e){
            e.stopPropagation();
        });
    },
  
    modalShow: function(){
        if (!this.isVisible) {
            Ext.get(this.getId()).removeCls(this.cfg.classes.invisible).addCls(this.cfg.classes.visible);
            this.cfg.elements.body.addCls(this.cfg.classes.locked);
            this.applyPositioning();
            this.isVisible = true;
            this.fireEvent('modalOpened', this.getId());
        }
    },
  
    applyPositioning: function(){
        var wWidth, wHeight, vWidth, vHeight, browserHeight, scrOfY, vTop, vLeft, oTop, oLeft, viewport, overlay;
        viewport = Ext.get(Ext.get(this.getId()).select('.'+this.cfg.classes.innerWrapper).elements[0]);
        overlay = Ext.get(Ext.get(this.getId()).select('.curtain').elements[0]);

        wWidth = (document.documentElement.clientWidth) ? document.documentElement.clientWidth : document.body.offsetWidth;
        wHeight = Ext.getBody().getHeight() + 35;
        
        if(!!this.modals[this.id].width){
            vWidth = this.modals[this.id].width;
            viewport.setWidth(vWidth);
        }
        else {
            vWidth = viewport.getWidth(); 
        }
         
        if(!!this.cfg.height){
            vHeight = this.cfg.height;
            viewport.setHeight(vHeight);
        }
        else {
            vHeight = viewport.getHeight();
        }
		         
        oLeft = !!this.cfg.overlayOffset.left?this.cfg.overlayOffset.left : 0;
        oTop = !!this.cfg.overlayOffset.top?this.cfg.overlayOffset.top : 0;

        if( typeof( window.innerWidth ) == 'number' ) { //!IE
            browserHeight = window.innerHeight;
            scrOfY = window.pageYOffset;
        } else if(document.documentElement.clientWidth) { //IE
            browserHeight = document.documentElement.clientHeight;
            scrOfY = document.documentElement.scrollTop;
        } else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
            browserHeight = document.body.clientHeight;
            scrOfY = document.body.scrollTop;
        }
	
        if(this.cfg.autoCenter.horz){
            vLeft = '50%';
            vMarginLeft = -(vWidth/2)+'px';
        } else {
            vLeft = !!this.cfg.viewportOffset.left?this.cfg.viewportOffset.left : 0;
            vLeft = vLeft + oLeft + 'px';
            vMarginLeft = '0px';
        }
    
        if(this.cfg.autoCenter.vert){
            if((browserHeight >= vHeight) && (!Ext.isIE6)){
                vTop = '50%';
                vMarginTop = -(vHeight/2)+'px';
            } else {
                Ext.get(this.dom.query('.' + this.cfg.classes.outerWrapper)).setStyle({'position': 'absolute'});
                vTop = (scrOfY+10)+'px';
                vMarginTop = '0px';
            }
        } else {
            Ext.get(this.dom.query('.' + this.cfg.classes.outerWrapper)).setStyle({'position': 'absolute'});
            vTop = !!this.cfg.viewportOffset.top ? this.cfg.viewportOffset.top : 0;
            vTop = vTop + oTop + 'px';
            vMarginTop ='0px';
        }
        
        //overlay.setX(oLeft).setY(oTop).setHeight(Ext.Element.getViewportHeight()).setWidth(Ext.Element.getViewportWidth());
        viewport.setStyle({
            'margin-left': vMarginLeft,
            'margin-top': vMarginTop,
            'left': vLeft,
            'top': vTop
        });
		
		if( vHeight > wHeight ){
			$j('.curtain').addClass('fixed')
		}
    },
  
    modalHide: function(){
        if(this.isVisible){
            this.fireEvent('modalClosed', this.getId());
            if(this.cfg.destroy){
    //    		Ext.get(this.getId()).remove();
                return false;
            } else {
                try{
                    Ext.get(this.getId()).removeCls(this.cfg.classes.visible).addCls(this.cfg.classes.invisible);
                    this.cfg.elements.body.removeCls(this.cfg.classes.locked);
                    this.isVisible = false;
                } catch(err) {
                    console.log('caught error: ', err);
                }
            }
			if( $j('.curtain.fixed').length > 0 ){
				$j('.curtain').removeClass('fixed');
			}
        }
    },
  
    getId: function(){
        return this.cfg.wrapperId + '-' + this.id;
    },
    buildOverlay: function(){
        var wrap, overlay, clone,
        overlay = {
            tag:'div',
            cls:this.cfg.classes.outerWrapper +' '+ this.cfg.classes.invisible,
            id: this.getId(),
            children:[{
            tag: 'div',
            cls: 'curtain'
          },{
            tag: 'div',
            cls: this.cfg.classes.innerWrapper,
            children:[{
              tag: 'div',
              cls: this.cfg.classes.buttonWrapper
            },{
              tag: 'div',
              cls: this.cfg.classes.contentWrapper
            }]
          }]
        };
        var rootNode = this.cfg.rootNode || this.cfg.elements.body.dom;
        this.dom.manip.append( rootNode, overlay);
        this.appendToolbar('#'+this.getId());
        try {
            wrap = Ext.get(this.getId()).select('.'+this.cfg.classes.contentWrapper);
            clone = this.cfg.elements.toOverlay.elements[0];
            cloneId = !!clone.getAttribute('id')?clone.getAttribute('id') : this.getId() + this.id;
            clone.setAttribute('id',clone.getAttribute('id') + '-in-overlay');
            Ext.get(clone).addCls('in-overlay').removeCls('hidden');
            wrap.appendChild(clone);
            this.toggle();
        } catch (err) {
            if (console && console.warn) {
                console.warn('ERROR', err);
            }
        }
    },
    
    appendToolbar: function(overlayID){
        var overlay = Ext.get(this.dom.query('.'+this.cfg.classes.buttonWrapper, this.getId())[0]),
            buttonsList = '<ul class="overlay-toolbar" id="overlay-'+this.id+'-toolbar"></ul>',
            buttonTemplate = '<li id="overlay-{overlay}-button-{id}" class="overlay-{overlay} modal-dialog-overlay-button {cls}">\
            <a href="{href}" title="{text}"><span>{text}</span></a>\
            </li>\
            ', toolbarID = 'overlay-'+this.id+'-toolbar';
        overlay.update(buttonsList);
        for(var i=0; i < this.cfg.buttons.length; i++){
            var buttonObj = this.cfg.buttons[i],
            button = new Ext.Template(buttonTemplate),
            ref = button.append(toolbarID, {
                cls: buttonObj.cls,
                text: buttonObj.text,
                href:'javascript:;',
                overlay:this.id,
                id: i
            });
            if(buttonObj.click){
                Ext.get('overlay-'+this.id+'-button-'+i).on('click', buttonObj.click);
            }
        }    
    },
    toggle: function(){
        if(this.isVisible) {
            this.modalHide();
        } else {
            this.modalShow();
        }
    }
});

Ext.define('Ext.EMC.ModalDisclaimer', {
    extend: 'Ext.EMC.Modal',
    constructor: function(params){
        var config= {};
        Ext.apply(config, params, {
            autoCenter:{
              vert:true,
              horz:true
            },
            width: 770,
            height: 430,
            buttons: [{
                text: 'Close',
                cls: 'close-btn-small'
            }],
            closeOnOverlayClick: true,
            destroy: false,
            
            // modal variables
            disclaimerId : 'disclaimerId',
            disclaimerTitle : 'disclaimerTitle',
            disclaimerCloseText : 'disclaimerCloseText',
            disclaimerURL : '#',
            callBackFunction: 'callBackFunction'
        });
        
        // modal template
        var tpl = new Ext.Template([
            '<div id="{id}" class="hidden disclaimer-modal">',
            '<h2>{title}</h2>',
            '<div class="remote-text"></div>',
            '<a class="close-link" href="#">{closeText}</a>',
            '</div>'
        ]);
        
        var el = tpl.append( Ext.getBody(), {
            id : config.disclaimerId,
            title : config.disclaimerTitle,
            closeText : config.disclaimerCloseText
        });
        
        // call parent
        this.callParent([[el], config]);
        
        // grab text from url
        var self = this;
        Ext.Ajax.request({
            url: config.disclaimerURL,
            success: function(response, opts) {
    
                Ext.get(self.getId()).query('.remote-text').first().innerHTML = response.responseText;
    
			    if (config.callBackFunction != null){
			     config.callBackFunction();
			    }
            },
            failure: function(response, opts) {
                if (console && console.log) {
                    console.log('Failed to load url. CODE: ' + response.status);
                }
            }
        });
        
        // add close btns events
        var container = Ext.get(this.getId());
        container.select('.close-btn-small a, .close-link').on('click', function(ev) { 
            ev.stopEvent();
            self.modalHide();
        });
    }
});

/*new header.js - 6/28/13 modified by 
 *rodrigo.berlochi@razorfish.com
 *This object runs an ajax call 
 *to check if a user is logged in, and get
 *its values. Those info is ready to use on several
 *ftl templates to create the loginModal. On win load, 
 *runs the core code, updating my account link and modal
 *based on that information.
 */

//Legacy from old header.js
/* workaround for dependency on Prototype's "Array.first()" method */
/* can come out once that dependency in this file is removed */
/* added 4/5/13 by tom.callahan@emc.com */
if (typeof(Array.prototype.first)!='function') {
    Array.prototype.first = function() {
        return this[0];
    };
};

var omnitureVars = omnitureVars || {};

/* BEGIN SET LOGIN PATH TO HANDLE REMOTE SITES */
var remoteSubdomains = [
	{str: 'estoretst', domain: 'stagefw-a.emc.com',   sufix: 'sr=emc.com'},
	{str: 'estoredev', domain: 'stagefw-a.emc.com',   sufix: 'sr=emc.com'},
	{str: 'estorestg', domain: 'stagefw-a.emc.com',   sufix: 'sr=emc.com'},
	{str: 'store',     domain: 'www.emc.com',         sufix: 'sr=emc.com'}
];
var loginPath = '/auth/login_redirect.htm';
for (var i = 0; i < remoteSubdomains.length; i++) {
	if (document.location.host.indexOf(remoteSubdomains[i].str) != -1) {
		loginPath = '//' + remoteSubdomains[i].domain + loginPath;
		break;
	}
}
/* END SET LOGIN PATH TO HANDLE REMOTE SITES */

//Create NS
Ext.ns('Ext.EMC');


//Start header process
window.onload = function(){
	// do not run this if there is no header HTML present
	if (Ext.select('#header').elements.length) {
		Ext.select('#headerRight ul li').removeCls('hide-for-resume');
	}
    //ensuring header update on campaign pages w/ collapsed header
    var headerShowMenu = $j('#headerShowMenu');
    if(headerShowMenu.length > 0){
            Ext.EMC.uwHeader.updateHeader();
            //call trackOmniture here to ensure that function is ready
            if(typeof(trackOmniture) === "function"){
                trackOmniture();
            }else{
                //console.log('trackOmniture is not defined');
            }
    };
};


//Header-user object
Ext.EMC.uwHeader = {
	
    isUserLogged : {//it's used on template to check if loginModal should be created [e.g.: legacyLayout.ftl]
	    status : false, //user isn't logged 
		values : null //not user data
	}, 
    init: function(){
		//this.updateHeader();
	},
	showLogginButton: function(){ 
	    //show my account button when process ends
	    if(!jQuery('body').hasClass('remoteHeaderHideLogin')){
	    	//if(!jQuery('body').hasClass('responsive-page')){
		        jQuery('#loginButton').show();
	    	/*}else{
	    		jQuery('#loginButton').addClass('showLogin');
	    	}*/
		}
	},
	createURLStoring: function(){
		/*Create a cookie to store the URL where is the user when it start the login process
		 * BE will read it to know where to redirect after the successful login*/
		
		try{
			var cookieName = "UW_LASTURLSTORED";
//			var redirectURL = window.location.host + window.location.pathname + window.location.search + window.location.hash;
			var redirectURL = window.location.host + window.location.pathname + window.location.search;
			//var domain = window.location.protocol+'//'+location.hostname+(location.port ? ':'+location.port: '');	
			
			for (var i = 0; i < remoteSubdomains.length; i++) {
				if (document.location.host.indexOf(remoteSubdomains[i].str) != -1) {
					if(remoteSubdomains[i].sufix && redirectURL.indexOf(remoteSubdomains[i].sufix) < 0) {
						var sufix = (redirectURL.indexOf("?") > 0 ? "&" : "?") + remoteSubdomains[i].sufix;
						redirectURL = redirectURL + sufix;
					}
					break;
				}
			}
			//window.location.hash has a bug in firefox when decoding. Implementing a crossbrowser solution.
			if(window.location.hash) {
				redirectURL = redirectURL + '#' + location.href.split('#').splice(1).join('#')
			}
			
			document.cookie = "" + cookieName + "=" + encodeURIComponent(redirectURL) + ";domain=.emc.com;path=/";
			
		}catch(err){
			console.log("Last URL cookie error = " + err.message);
		}
		
	},
	updateHeader: function() {
	    var self = this;
	    //store DOM objects
	    var headerDesktop = Ext.select('#headerRight li a').first(); 
        var headerMobile = Ext.select('#loginButtonMobile a').first(); 
		
		
		//getUserInfo -> "not user logged in"
		if(this.isUserLogged.status == false){ 
			
			Ext.get(headerDesktop).set({href : '/login.htm'});
			
			if (headerMobile){
			    Ext.get(headerMobile).set({href : '/login.htm'});
			};

			this.showLogginButton();
			
			jQuery('a[href$="/login.htm"]').click(function (e){
				e.preventDefault();
				self.createURLStoring();
				window.location.href = loginPath;
			})
			return; 
			
		}else{
			    //getUserInfo -> "user logged in"
				
				//store a shortcut to the object literal
			    var ud = Ext.EMC.uwHeader.isUserLogged.values
				
			    if((ud.firstName == '') && (ud.lastName == '')){
			    	headerDesktop.dom.innerHTML = ud.userName;
			    }else{
			    	headerDesktop.dom.innerHTML = ud.firstName + ' '+ ud.lastName;	
			    }
				
				//avoid opening login lightbox if user is logged in
				headerDesktop.removeCls('openlightbox').set({href : ''});
				
				this.showLogginButton();
				
				if (headerMobile) {
					headerMobile.dom.innerHTML = 'Logout';
					Ext.get(headerMobile).set({href : '/logout.htm'}).removeCls('mobileLogin').addCls('mobileLogout');
				}
				
				//create my account modal
				this.createMyAccountModal(ud, headerDesktop);
				
		} //END else
		
		
	    
	},
	resumeName: function(){
	    var limit = 26;
	    var chars = Ext.select('#headerRight li a').first();
        var numberchars = chars.dom.innerHTML;
        if (numberchars.length > limit) {
	        newchars = numberchars.substr(0, limit-1);
	        var totalchar = newchars + "...";
	        Ext.fly('headerRight').select('li a').first().update(totalchar);
	        Ext.select('#headerRight ul li').removeCls('hide-for-resume');
        }
	},
	createMyAccountModal : function(ud, headerDesktop){
	            var modalMyAccount = null; 
				try {
					var headerDesktop = Ext.select('#headerRight li a').first(); 
					headerDesktop.on('click', function(ev){
						ev.stopEvent();
						if (modalMyAccount) {
							modalMyAccount.modalShow();
						} else {
							//update user data
							var repFullname = jQuery('#myAccountModal .my-account-fullname');
							if (repFullname) {
								repFullname.html(ud.firstName + ' '+ ud.lastName); 
							}
							var repUsername = jQuery('#myAccountModal .my-account-username');
							if (repUsername) {
								repUsername.html(ud.userName); 
							}
							modalMyAccount = new Ext.EMC.Modal("#myAccountModal", {
								autoCenter: {
									vert:true,
									horz:true
								},
								width: 580,
								height: 265,
								buttons: [{
									text: 'Close',
									cls: 'close-btn-small'
								}],
								closeOnOverlayClick: true,
								destroy: false,
								rootNode :$j('body')[0]
							});
							Ext.get(modalMyAccount.getId()).select('.close-btn-small a').on('click', function(ev) { 
								ev.stopEvent();
								modalMyAccount.modalHide();
							});
						}
					});
				} catch (e) {
					console && console.log && console.log(e);
				}
	},
	setOmnitureValues: function(data){
		/*
		 * @data:  object wrapping user values 
		 * @sets those values for Omniture tracking
		 */
		omnitureVars = omnitureVars || {}; //it's defined globally in  omniture_script_header.inc
		var d = data, 
		    i = 0;
		
		for(i; i<d.length; i++){
		    
			var text = d[i].text;
			var code = d[i].code;
			
			//following attributes are transformed from string to array of integers
			if(code == "credentialEntitlements" || code == "identityEntitlements" || code == "programEntitlements"){
				text = text.split(','); //create array
			}
			
			omnitureVars["" + code + ""] = text;
		}
		
		
		/*
		 *trackOmniture(); -> invoking it below on doc ready to ensure it's defined
		 *It does the value tracking using the omnitureVars object, and it's defined externally
		 **/

	},
	getUserInfo: function(){
	
		function readAnswer(data){
		
			if(data.responseText !== '[]'){ //means user is logged
			  
				//var obj = jQuery.parse(data.responseText);
				var obj = Ext.JSON.decode(data.responseText);

				//so, change properties to user-logged state
				Ext.EMC.uwHeader.isUserLogged.status = true; 
				
				var firstName = lastName = userName = '';
				
				for(var i=0; i<obj.length; i++){
			        var value = obj[i].code;
			        switch(value){
			            case 'firstName':
			                firstName = obj[i].text;
			            break;
			            case 'lastName':
			                lastName = obj[i].text;
			            break;
			            case 'userName':
			                userName = obj[i].text;
			            break;
			            //default: do nothing
			       }
			    };
				
				Ext.EMC.uwHeader.isUserLogged.values = {
					userName : userName,
					firstName : firstName,
					lastName : lastName
				};
				
				Ext.EMC.uwHeader.setOmnitureValues(obj);
			}
			
			Ext.onReady(function(){
				Ext.EMC.uwHeader.updateHeader();
				callToOmniture();
			});
            
		};
		
        function outputErrAnswer(){
			console.log('Error on userInfo request');
			jQuery(document).ready(function(){
				Ext.EMC.uwHeader.updateHeader();
				
				callToOmniture();
			});
		};
        
        function callToOmniture(){
            //call trackOmniture here to ensure that function is ready
            if(typeof(trackOmniture) === "function"){
                trackOmniture();
            }else{
                //console.log('trackOmniture is not defined');
            }
        };
		
        Ext.Ajax.request({
           url: '/userInfo.htm',
           method: 'GET',
           success: readAnswer,
           failure: outputErrAnswer
        });
			
	}
};

//running it so isUserLogged.status is available and 
//updated for the script which create the loginModal (FTL files)
Ext.EMC.uwHeader.getUserInfo();

/* Footer.js */
UW.util.loader.js(['//use.typekit.net/fmn1ayd.js'], function(){
	try{Typekit.load({
    loading: function() {
      jQuery(window).triggerHandler('typekit.fonts.loading');
    },
    active: function() {
      jQuery(window).triggerHandler('typekit.fonts.ready');
      jQuery(window).triggerHandler('typekit.fonts.active');
    },
    inactive: function() {
      jQuery(window).triggerHandler('typekit.fonts.ready');
      jQuery(window).triggerHandler('typekit.fonts.inactive');
    },
    fontactive: function(familyName, fvd) {
      jQuery(window).triggerHandler('typekit.font.active',{familyName: familyName, fvd: fvd});
    }
  });}catch(e){};
});



/* <<< Start inboundBar.js */

var $j = $j ? $j : jQuery.noConflict();

/// start old code to FW backwards compat
var ibBackwardsCompat = {
    suppress: false,
    suppressURLs: ['/emc-plus/']
};
if (typeof (inboundBar) !== 'undefined') {
    if (typeof (inboundBar.suppress) !== 'undefined'){
        ibBackwardsCompat.suppress = inboundBar.suppress;
    }
    if (typeof (inboundBar.suppressURLs) !== 'undefined') {
        ibBackwardsCompat.suppressURLs = ibBackwardsCompat.suppressURLs.concat(inboundBar.suppressURLs);
    }
}
/// end of backwards compat code

var inboundBar = {
       suppress: ibBackwardsCompat.suppress,
       suppressURLs: ibBackwardsCompat.suppressURLs,
       maxH: 0,
       allSliders: [],
       isOpen: false,
       ease: '',
       /**
        * send debug info to console if present, otherwise fail silently
        * @returns {undefined}
        */
       trace: function () {
           if (typeof (console) !== 'undefined') {
               if (typeof (console.log) !== 'undefined') {
                   for (i = 0; i < arguments.length; i++) {
                       console.log(arguments[i]);
                   }
               }
           }
       },
       disableSelection: function (target) {
           if (typeof target.onselectstart !== "undefined") { //IE route
               target.onselectstart = function () {
                   return false;
               };
           }
           else if (typeof target.style.MozUserSelect != "undefined") { //Firefox route
               target.style.MozUserSelect = "none";
           }
           else {//All other route (ie: Opera)
               target.onmousedown = function () {
                   return false;
               };
           }
       },
       isMobile: function () {
           var userAgent = navigator.userAgent.toLowerCase();

           return (window.location.href.indexOf('?forceios') >= 0 ||
               userAgent.search('android') >= 0 ||
               userAgent.search('iphone') >= 0 ||
               userAgent.search('ipad') >= 0 ||
               userAgent.search('ipod') >= 0
               );
       },
       eventTypes: {
           'down': function () {
               return inboundBar.isMobile() ? 'touchstart' : 'mousedown';
           },
           'up': function () {
               return inboundBar.isMobile() ? 'touchend' : 'mouseup';
           },
           'over': function () {
               return inboundBar.isMobile() ? 'touchstart' : 'mouseenter';
           },
           'out': function () {
               return inboundBar.isMobile() ? 'touchend' : 'mouseleave';
           }
       },
       // MAIN UI /////////////////////////////////////////////////////////////
       timings: {
           initial: 500,
           initialDelay: 100,
           openClose: 250,
           instant: 1
       },
       /**
        * global header-footer dropdown rollover timeout
        */
       ghfDdRoTO: 0,
       init: function () {

           var deferred = new $j.Deferred();

           $j('.ib-icon .emclp-simulate-click').removeClass('emclp-simulate-click'); // TO CHECK, why is that?

           // suppress entire inbound bar for a page -- place "var inboundBar={ suppress: true };" in page's JS
           for (var i = 0; i < inboundBar.suppressURLs.length; i++) {
               if (window.location.pathname.indexOf(inboundBar.suppressURLs[i]) == 0) {
                   inboundBar.suppress = true;
               }
           }

           if ($j('#inboundBar').length && inboundBar.suppress !== true) {

               // suppress individual contact items by physically removing them from the page prior to processing
               // place "var inboundBar={ suppress: 'sales-chat,support-chat,request-quote,email-us,phone' };" in page's JS
               // (but only include the ones you actually want to remove in the list)
               if (typeof (inboundBar.suppress) == 'string') {
                   inboundBar.suppress = inboundBar.suppress.split(',');
                   for (var i = 0; i < inboundBar.suppress.length; i++) {
                       $j('#inboundBar .ib-icon.ib-icon-' + inboundBar.suppress[i]).remove();
                   }
               }

               if (typeof ($j.easing.easeInOutQuad) != 'function') {
                   // monkey patch with easing equation if it doesn't exist
                   $j.extend($j.easing, {
                       easeInOutQuad: function (x, t, b, c, d) {
                           if ((t /= d / 2) < 1)
                               return c / 2 * t * t + b;
                           return -c / 2 * ((--t) * (t - 2) - 1) + b;
                       }
                   });
               }

               // get initial y pos in case page has overridden it, store for use later
               inboundBar.initialY = parseInt($j('#inboundBar').css('top'));

               // prevent lync icon in phone numbers -- temporary fix until proper Lync support can be worked out
               // happens again when user clicks to open IB since Lync sometimes runs later than this line
               inboundBar.tempLyncWorkaround();

               // remove old style social button bars and copy HTML for responsive version on responsive pages
               $j('#socialmediabar, #socialBar').remove();
               if (!$j('body').hasClass('sidebar-search-field_medium-size')) { // $j('body').hasClass('responsive-page') && now we asume all to be responsive
                   $j('#navigation_wrapper').after($j('#inboundBar').clone().attr('id', 'inboundBarResp'));
                   $j('#inboundBarResp').width(0).find('.ib-content-inner').attr('style', '');
                   $j('#navigation_wrapper #searchFormWrapper.searchFormWrapper').addClass('isHidden');
                   if ($j('#headerWrap #header #headerTop .btn-inboundbar').length == 0) {
                       $j('#headerWrap #header #headerTop').append('<a class="btn btn-inboundbar"></a>');
                   }
               }

               // more inits
               $j('body').addClass('hasInboundBar');
               inboundBar.allSliders = $j('#inboundBar .ib-slider');

               // copy text from localization HTML elements to JS objects, remove
               $j('#inboundBarText').children().each(function (ix, el) {
                   inboundBar.textPieces[$j(el).attr('class')] = $j(el).html();
               });
               $j('#inboundBarText').remove();

               // add tab, icon, error notice, and other structure (to simplify HTML)
               $j('#inboundBar .ib-slider').prepend('<div class="ib-tab-bg"><div class="ib-tab-topend"></div><div class="ib-tab-end"></div></div>');
               $j('#inboundBar .ib-icon').each(function (ix, el) {
                   $j(el).find('a').each(function (ix1, el1) {
                       if (ix1 == 0) {
                           $j(el1).wrapInner('<div class="ib-icon-text-label" />').prepend('<div class="ib-icon-wrapper"></div>').append('<div class="clearBothTight"></div>');
                       } else {
                           $j(el1).wrapInner('<div class="ib-icon-text-label" />').append('<div class="clearBothTight"></div>');
                       }
                   });
               });

               $j('#inboundBarResp .ib-icon').each(function (ix, el) {
                   if ($j(el).find('a').length > 1) {
                       $j(el).wrapInner('<div class="ib-icon-multi-link-wrap"></div>').prepend('<div class="ib-icon-wrapper"></div>');
                       $j(el).find('a').wrapInner('<div class="ib-icon-text-label" />').append('<div class="clearBothTight"></div>');
                   } else {
                       $j(el).find('a').wrapInner('<div class="ib-icon-text-label" />').prepend('<div class="ib-icon-wrapper"></div>').append('<div class="clearBothTight"></div>');
                   }
               });

               $j('.inboundBar .ib-icon').append('<div class="clearBothTight"></div>');
               $j('.ib-contact-content-inner').append('<div class="ib-error-popup"><table><tr><td align="center" valign="middle"><div class="ib-error-notice"></div><div class="ib-error-button ib-button">' + inboundBar.getTextPiece('ib-button-ok') + '</div></td></tr></table></div>');
               // open panel TL corner icon
               $j('#inboundBar .ib-sliderContact .ib-contact-content-inner').prepend('<div class="ib-content-inner-icon"></div>');

               $j('#inboundBar').addClass('setup');


               // layout calculations and HTML updates

               $j('#inboundBar .ib-slider').width(960);
               // adjust slider widths to fit icons dynamically
               var temp = 0;
               $j('#inboundBar .ib-sliderContact .ib-content-inner li').each(function (ix, el) {
                   temp += $j(el).outerWidth() + parseInt($j(el).css('margin-right'));
               });
               $j('#inboundBar .ib-sliderContact .ib-content-inner').width(temp);
               temp = 0;
               $j('#inboundBar .ib-sliderContact .ib-content-inner li').each(function (ix, el) {
                   temp += $j(el).outerWidth() + parseInt($j(el).css('margin-right'));
               });
               $j('#inboundBar .ib-sliderContact .ib-content-inner').width(temp);
               // adjust chat slider height to fit rollovers dynamically
               temp = 0;
               $j('#inboundBar .ib-sliderContact .ib-content-inner .ib-contact-rollover').each(function (ix, el) {
                   temp = Math.max($j(el).outerHeight(), temp);
               });

               $j('.ib-sliderShare .ib-content').each(function (ix, el) {
                   $j(el).height(Math.max($j(el).siblings('.ib-tab').outerHeight(), $j(el).find('.ib-content-inner').outerHeight()));
               });
               $j('#inboundBar .ib-slider').each(function (ix, el) {
                   $j(el).width($j(el).find('.ib-tab').outerWidth() + $j(el).find('.ib-content').outerWidth());
               });
               $j('.inboundBar .ib-contact-rollover').each(function (ix, el) {
                   $j(el).attr('ix', ix);
               });
               inboundBar.disableSelection($j('#inboundBar')[0]);

               // radio boxes
               inboundBar.forms.radio.init();

               inboundBar.spinner.init();

               $j('#inboundBar').removeClass('setup').addClass('setup-complete');

               setTimeout(inboundBar.closeAllTabs, inboundBar.timings.initialDelay / 2);

               // attach events

               $j('#inboundBar .ib-tab, #inboundBar .ib-tab-topend, #inboundBar .ib-tab-end, #inboundBar .ib-tab-bg').bind(inboundBar.eventTypes.down(), inboundBar.onTabClick);
               $j('body').bind(inboundBar.eventTypes.down(), inboundBar.onTabBodyClick);
               $j('body').bind('click', inboundBar.onTabBodyClickBlock);

               if (typeof animateNav === 'function') { // $j('body').hasClass('responsive-page') now we asume all to be responsive

                   $j('.btn.btn-inboundbar').click(function () {
                       animateNav('right'); // in responsive GHF
                   });
                   // click icon to reveal search field
                   $j('#navigation_wrapper #searchFormWrapper.searchFormWrapper.isHidden').click(function (ev) {
                       $j('#navigation_wrapper #searchFormWrapper.searchFormWrapper').removeClass('isHidden').find('input').focus();
                   });
                   $j('#inboundBarResp .ib-icon, .inboundBar .ib-icon .emailUsOverlayLink').click(animateNav);


               }

               $j('#inboundBar .ib-sliderContact .ib-icon').bind('mouseenter touchstart', inboundBar.onContactRollover);
               $j('#inboundBar .ib-sliderContact .ib-icon').bind('click', inboundBar.onContactClick);
               $j('.inboundBar .ib-icon .emailUsOverlayLink').click(inboundBar.closeAllTabs);
               $j('.inboundBar .nullLink').click(function (ev) {
                   ev.preventDefault();
               });
               $j('#header #menu .menuItem').bind(inboundBar.eventTypes.over(), function (ev) {
                   if (ev.type == 'mouseenter') {
                       inboundBar.ghfDdRoTO = setTimeout(inboundBar.closeAllTabs, 200);
                   }
               });
               $j('#header #menu .menuItem').bind(inboundBar.eventTypes.out(), function (ev) {
                   if (ev.type == 'mouseleave') {
                       clearTimeout(inboundBar.ghfDdRoTO);
                   }
               });
               $j('.ib-button-social-more').click(inboundBar.social.onMoreClick);

               inboundBar.errors.init();

               // reveal

               $j('#inboundBar .ib-slider-wrapper').css('right', '0px').delay(inboundBar.timings.initialDelay).animate({
                   right: '40px'
               }, inboundBar.timings.initial, $j.easing.easeOutQuad);

           }

           return deferred.resolve();
       },
       textPieces: {},
       // legacy support
       getTextPiece: function (which) {
           return inboundBar.translations.getTranslation(which, inboundBar.translations.getDefaultLang());
       },
       // REVISAR
       //(inboundBar.translations ? inboundBar.translations : {}),
       translations: {
           getDomainKey: function () {
               if (emclp.simulatedURL) {
                   var temp = emclp.simulatedURL.slice(emclp.simulatedURL.indexOf('//') + 2);
                   return temp.slice(0, temp.indexOf('/')).toLowerCase().split('.').join('').split('-').join('').split('emccom').join('').split('emclocal').join('');
               } else {
                   return window.location.hostname.toLowerCase().split('.').join('').split('-').join('').split('emccom').join('').split('emclocal').join('');
               }
           },
           getDefaultLang: function () {
               var lang = 'en_US';
               if (typeof (emcDomainMap[inboundBar.translations.getDomainKey()]) != 'undefined') {
                   lang = emcDomainMap[inboundBar.translations.getDomainKey()];
               }
               return lang;
           },
           getTranslation: function (piece, lang) {
               if (typeof (inboundBar.translations[lang]) != 'undefined') {
                   if (typeof (inboundBar.translations[lang][piece]) != 'undefined') {
                       return inboundBar.translations[lang][piece];
                   } else {
                       if (typeof (inboundBar.translations[inboundBar.translations.getP9Fallback()][piece]) != 'undefined') {
                           return inboundBar.translations[inboundBar.translations.getP9Fallback()][piece];
                       } else {
                           return '';
                       }
                   }
               } else {
                   if (typeof (inboundBar.translations[inboundBar.translations.getP9Fallback()][piece]) != 'undefined') {
                       return inboundBar.translations[inboundBar.translations.getP9Fallback()][piece];
                   } else {
                       return '';
                   }
               }
           },
           getP9Fallback: function () {
               if (typeof (emcDomainMapP9[subDomain]) != 'undefined') {
                   return emcDomainMapP9[subDomain];
               } else {
                   return 'en_US';
               }
           }
       },
       /* SPINNER PNG ANIM */
       spinner: {
           baseSpriteX: -86,
           spriteW: 32,
           numFrames: 12,
           html: '<div class="ib-spinner" data-spinner-frame="0"><div class="ib-spinner-inner"></div></div>',
           ticker: function () {
               $j('.ib-spinner').each(function (ix, el) {
                   var cFrame = $j(el).attr('data-spinner-frame');
                   cFrame++;
                   if (cFrame >= inboundBar.spinner.numFrames) {
                       cFrame %= inboundBar.spinner.numFrames;
                   }
                   $j(el).attr('data-spinner-frame', cFrame);
                   $j(el).find('.ib-spinner-inner').css({
                       backgroundPosition: (inboundBar.spinner.baseSpriteX - (cFrame * inboundBar.spinner.spriteW)) + 'px -2px'
                   });
               });
           },
           init: function () {
               inboundBar.spinner.tick = setInterval(inboundBar.spinner.ticker, 80);
           },
           create: function (el) {
               $j(el).children('.ib-spinner').remove();
               $j(el).css({position: 'relative'});
               $j(el).append(inboundBar.spinner.html);
           },
           destroy: function (el) {
               $j(el).children('.ib-spinner').remove();
           }
       },
       tempLyncWorkaround: function () {
           $j('.ib-icon.ib-icon-phone nobr').each(function (ix, el) {
               var temp = $j(el).find('span').text();
               temp = temp.split(' ').join('<nobr>&nbsp;</nobr>');
               temp = temp.split('+').join('<nobr>+</nobr>');
               temp = temp.split('0').join('<nobr>0</nobr>');
               temp = temp.split('1').join('<nobr>1</nobr>');
               temp = temp.split('2').join('<nobr>2</nobr>');
               temp = temp.split('3').join('<nobr>3</nobr>');
               temp = temp.split('4').join('<nobr>4</nobr>');
               temp = temp.split('5').join('<nobr>5</nobr>');
               temp = temp.split('6').join('<nobr>6</nobr>');
               temp = temp.split('7').join('<nobr>7</nobr>');
               temp = temp.split('8').join('<nobr>8</nobr>');
               temp = temp.split('9').join('<nobr>9</nobr>');
               $j(el).find('span').replaceWith(temp);
           });
       },
       /* SLIDERS */

       onTabBodyClick: function (ev) {
           if (inboundBar.isOpen) {
               if ($j(ev.target).closest('.ib-slider').length == 0) {
                   ev.preventDefault();
                   inboundBar.closeAllTabs();
               }
           }
       },
       onTabBodyClickBlock: function (ev) {
           if (inboundBar.isOpen) {
               if ($j(ev.target).closest('.ib-slider').length == 0) {
                   ev.preventDefault();
               }
           }
       },
       onTabClick: function (ev) {
           var thisSlider = $j(ev.target).closest('.ib-slider');
           inboundBar.isOpen = true;
           inboundBar.onContactRollover();
           // reset
           $j('#inboundBar').css({
               top: '0px'
           });
           $j('#inboundBar .ib-slider-wrapper').css({
               top: inboundBar.initialY + 'px'
           });
           if (!thisSlider.hasClass('ib-tab-open')) {
               inboundBar.adjustTabWidth(thisSlider);
           } else if (thisSlider.hasClass('ib-tab-open')) {
               // clicked on a tab that's open
               inboundBar.closeAllTabs();
           }
           inboundBar.tempLyncWorkaround();
       },
       adjustTabWidth: function (thisSlider) {
           var otherSliders = thisSlider.siblings('.ib-slider');
           // clicked on a tab that's not open
           thisSlider.addClass('ib-tab-open').removeClass('ib-tab-closed');
           otherSliders.addClass('ib-tab-closed').removeClass('ib-tab-open');
           thisSlider.stop().clearQueue().animate({
               width: (thisSlider.find('.ib-content-inner').outerWidth() + 40) + 'px',
               left: '-' + thisSlider.find('.ib-content-inner').outerWidth() + 'px',
               height: inboundBar.getSliderHeight(thisSlider) + 'px'
           }, inboundBar.timings.openClose, inboundBar.ease, function () {
               thisSlider.addClass('ib-tab-open').removeClass('ib-tab-closed');
           });
           otherSliders.each(function (ix, el) {
               $j(el).stop().clearQueue().animate({
                   left: '0px',
                   height: $j(el).find('.ib-tab').outerHeight() + 'px'
               }, inboundBar.timings.openClose, inboundBar.ease);
           });

           $j('#inboundBar').stop().css({height: '100%'}).clearQueue().animate({
               width: (thisSlider.find('.ib-content-inner').outerWidth() + 40) + 'px'
           }, inboundBar.timings.openClose);
           // remove classes now that calcs are done, will be reapplied at end of anim for visual appearance
           thisSlider.removeClass('ib-tab-open').addClass('ib-tab-closed');
           if (thisSlider.attr('id') == 'ib-sliderContact') {
               inboundBar.onContactRollover();
           }
       },
       /* pass-through for compatibility */
       closeAll: function () {
           inboundBar.closeAllTabs();
       },
       closeAllTabs: function () {
           // reset
           $j('.ib-error-notice .ib-error-button').unbind('click', inboundBar.closeAllTabs);
           $j('#inboundBar').css({
               top: inboundBar.initialY + 'px'
           });
           $j('#inboundBar .ib-slider-wrapper').css({
               top: '0px'
           });
           //inboundBar.isOpen=false;
           $j(inboundBar.allSliders).addClass('ib-tab-closed').removeClass('ib-tab-open');
           $j(inboundBar.allSliders).each(function (ix, el) {
               $j(el).stop().clearQueue().animate({
                   left: '0px',
                   height: $j(el).find('.ib-tab').outerHeight() + 'px'
               }, inboundBar.timings.openClose, inboundBar.ease);
           });

           $j('#inboundBar').stop().clearQueue().delay(inboundBar.timings.openClose).animate({
               width: '41px',
               height: (function (){
                   var ibSlideWrapperPosition = $j('#inboundBar .ib-slider-wrapper').position() || 0,
                       positionTop = ibSlideWrapperPosition ? ibSlideWrapperPosition.top : 0 ;
                   
                    return inboundBar.getNewTotalHeight() + positionTop + 5;
               })()
           }, inboundBar.timings.instant, function () {
               inboundBar.isOpen = false;
           });

       },
       getSliderHeight: function (el) {
           if ($j(el).hasClass('ib-tab-open')) {
               return Math.max($j(el).find('.ib-tab').outerHeight(), $j(el).find('.ib-content').outerHeight());
           } else {
               return Math.max($j(el).find('.ib-tab').outerHeight());
           }
       },
       getNewTotalHeight: function () {
           var nH = 0;
           $j(inboundBar.allSliders).each(function (ix, el) {
               nH += inboundBar.getSliderHeight(el);
           });
           return nH;
       },
       /* CONTACT SLIDER FUNC */
       tempObj: {
           pos: -439
       },
       cContactRollover: 0,
       onContactRollover: function (ev) {
           var evEl;
           var force = false;
           var thisClass;
           var targetClass;
           if (typeof (ev) == 'undefined') {
               force = true;
               evEl = $j('#inboundBar .ib-sliderContact .ib-icon').eq(inboundBar.cContactRollover);
           } else {
               evEl = $j(ev.target).closest('.ib-icon');
               inboundBar.cContactRollover = Number(evEl.attr('ix'));
           }
           if (typeof (ev) != 'undefined' && !evEl.hasClass('ib-icon-rolledover')) {
               ev.preventDefault();
           }
           if (evEl.length) {
               evEl.addClass('ib-icon-rolledover').siblings('.ib-icon').removeClass('ib-icon-rolledover');
               thisClass = evEl[0].className.replace('ib-icon', '').replace('ib-icon-no-rollover', '').replace('ib-icon-rolledover', '').replace('ib-icon-large', '').replace('ib-icon-small', '').split(' ').join('');
               targetClass = thisClass.replace('icon', 'rollover');
               var zeroPointOffset = -490;
               var iconOffset = 0;
               if (!evEl.closest('.ib-slider').is(':animated') || force) {
                   $j('#inboundBar .' + targetClass).show();
                   $j('#inboundBar .' + targetClass).siblings().hide();
                   iconOffset = Math.max(-439, Math.round(zeroPointOffset + (evEl.position().left - parseInt(evEl.closest('.ib-content-inner').css('padding-left')) + (evEl.width() / 2))));
                   if ($j('#inboundBar .ib-contact-rollovers').css('display') == 'none') {
                       $j('#inboundBar .ib-contact-rollovers').css({
                           //display: 'block',
                           backgroundPosition: iconOffset + 'px -434px'
                       });
                       inboundBar.tempObj.pos = iconOffset;
                   } else {
                       $j(inboundBar.tempObj).stop().clearQueue().animate({
                           pos: iconOffset
                       }, {
                           step: function () {
                               $j('#inboundBar .ib-contact-rollovers').css({backgroundPosition: Math.round(inboundBar.tempObj.pos) + 'px -434px'});
                           },
                           duration: 125,
                           easing: inboundBar.ease
                       });
                   }
               }
           }
       },
       onContactClick: function (ev) {
           $j('.inboundBar .ib-contact-content').show();
           var evEl = $j(ev.target).closest('.ib-icon');
           var matchingClass = 'ib-contact-content' + evEl.attr('class').split('ib-icon-rolledover').join('').split('ib-icon-large').join('').split('ib-icon-small').join('').split('ib-icon').join('').split(' ').join('');
           if ($j('.' + matchingClass).length) {
               ev.preventDefault();
               $j(evEl).closest('.ib-slider').addClass('ib-has-icon-selected');
               $j(evEl).closest('.ib-slider').find('.ib-contact-rollovers').hide();
               $j(evEl).addClass('ib-icon-selected').siblings('.ib-icon').removeClass('ib-icon-selected');
               var thisClass = evEl[0].className.replace('ib-icon', '').replace('ib-icon-no-rollover', '').replace('ib-icon-rolledover', '').replace('ib-icon-selected', '').replace('ib-icon-large', '').replace('ib-icon-small', '').split(' ').join('').replace('ib-icon', 'ib-contact-content');
               $j(evEl).closest('.ib-content-inner').find('.' + thisClass).show().siblings().hide();
               // adjust slider width to fit content dynamically
               $j('#inboundBar .ib-sliderContact .ib-content-inner').width($j('#inboundBar .ib-contact-content').outerWidth());
               inboundBar.adjustTabWidth($j(evEl).closest('.ib-slider'));
               inboundBar.contactSliderInits[thisClass.replace('ib-contact-content-', '')]();
               inboundBar.errors.close();
           } else {
               inboundBar.closeAllTabs();
           }
       },
       // SOCIAL /////////////////////////////////////////////////////////////

       // retrofitting IB2 "More" button to IB1 system to fix security hole in AddThis
       // SOCIAL /////////////////////////////////////////////////////////////
       //$j('.ib-content-inner a.addthis_button_compact').removeClass('addthis_button_compact').addClass('ib-button-social-more').attr('href','#');
       social: {
           onMoreClick: function (ev) {
               ev.preventDefault();
               if (!$j('#nightShadeContainerContent').find('#ib-social-more-overlay').length) {
                   $j('#nightShadeContainerContent').append('<div id="ib-social-more-overlay" class="overlayPage"><div id="ib-social-more-overlay-addthis" class="addthis_toolbox addthis_default_style addthis_32x32_style"><h3>' + $j('#inboundBar .ib-sliderShare .addthis_toolbox h3').eq(0).text() + '</h3></div></div>');
                   for (var i = 1; i <= 20; i++) {
                       $j('#ib-social-more-overlay-addthis').append('<a class="addthis_button_preferred_' + i + '"></a>');
                       if (i % 5 == 0) {
                           $j('#ib-social-more-overlay-addthis').append('<br/>');
                       }
                   }
                   $j('#ib-social-more-overlay-addthis').append('<div class="clearBothTight"></div>');
                   addthis.toolbox('#ib-social-more-overlay-addthis');
               }
               openOverlay('ib-social-more-overlay');
               inboundBar.closeAll();
           }
       },
       // FORMS /////////////////////////////////////////////////////////////
       forms: {
           validate: function (el, isBeforeSubmit) {
               var val;
               var defaultVal;
               var type = $j(el).attr('validate-type');
               var pass = false;
               var required = $j(el).hasClass('ib-form-field-required');
               $j(el).val($j(el).val().split('"').join(''));
               switch (type) {
                   case 'email':
                       val = $j(el).val();
                       defaultVal = $j(el).attr('default-value');
                       var emailRegex = /^(['a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/;
                       pass = emailRegex.test(val);
                       break;
                   case 'alpha_numeric':
                       val = $j(el).val();
                       defaultVal = $j(el).attr('default-value');
                       pass = (val != '') && (val != defaultVal);
                       break;
                   case 'numeric':
                       val = $j(el).val();
                       defaultVal = $j(el).attr('default-value');
                       pass = (val != '') && (val != defaultVal) && !isNaN(val) && !Boolean($j(el).val().match(/[^\d.]/g));
                       $j(el).val($j(el).val().replace(/[^\d.]/g, ''));
                       if ($j(el).val() == '') {
                           $j(el).val($j(el).attr('default-value'));
                       }
                       break;
                   case 'dropdown':
                       val = el.selectedIndex;
                       defaultVal = 0;
                       pass = (val != defaultVal) || (val == defaultVal && $j(el).hasClass('ib-form-field-disabled'));
                       break;
                   default:
               }
               if (required && pass) {
                   pass = true;
               } else if (!required && ((val != '') || (val != defaultVal))) {
                   pass = true;
               } else {
                   pass = false;
               }
               if (isBeforeSubmit) {
                   if (pass) {
                       $j(el).removeClass('ib-field-failed-validation');
                       $j(inboundBar.forms.getJSSelectFromHTMLSelect(el)).removeClass('ib-field-failed-validation');
                   } else {
                       $j(el).addClass('ib-field-failed-validation');
                       $j(inboundBar.forms.getJSSelectFromHTMLSelect(el)).addClass('ib-field-failed-validation');
                   }
               } else {
                   if (pass || val == defaultVal) {
                       $j(el).removeClass('ib-field-failed-validation');
                       $j(inboundBar.forms.getJSSelectFromHTMLSelect(el)).removeClass('ib-field-failed-validation');
                   } else {
                       $j(el).addClass('ib-field-failed-validation');
                       $j(inboundBar.forms.getJSSelectFromHTMLSelect(el)).addClass('ib-field-failed-validation');
                   }
               }
               return pass;
           },
           hasRedirectableValueChosen: function (el) {
               var chosen = false;
               var el = $j(el);
               if (el.hasClass('ib-form-field-dropdown')) {
                   el.find('option').each(function (ix1, el1) {
                       if (el1.selected && typeof ($j(el1).attr('data-alt-url')) != 'undefined') {
                           chosen = true;
                       }
                   });
               }
               return chosen;
           },
           textFieldOnBlur: function (ev) {
               var el = $j(ev.target).closest('.ib-form-field');
               //window.alert(el);
               if ($j(el).val() == '' || $j(el).val() == $j(el).attr('default-value')) {
                   $j(el).val($j(el).attr('default-value')).addClass('ib-form-field-default');
               }
               inboundBar.forms.validate(el);
           },
           textFieldOnFocus: function (ev) {
               var el = $j(ev.target).closest('.ib-form-field');
               //window.alert(el);
               $j(el).removeClass('ib-field-failed-validation');
               if ($j(el).val() == $j(el).attr('default-value')) {
                   $j(el).val('').removeClass('ib-form-field-default');
               }
           },
           createField: function (target, params) {
               var fieldEl;

               var theDefaultClass = (params.lastKnownValue != '') ? '' : ' ib-form-field-default';
               var theRequiredClass = (params.mandatory) ? ' ib-form-field-required' : ' ib-form-field-optional';

               switch (params.type) {

                   case 'Text Field':
                       var theVal = (params.lastKnownValue != '') ? params.lastKnownValue : params.label;
                       fieldEl = $j('<input class="ib-form-field ib-form-field-text' + theDefaultClass + theRequiredClass + '" type="text" order="' + params.order + '" validate-type="' + params.validationType + '" lpid="' + params.id + '" name="f' + params.id + '" id="ib-form-element-' + params.id + '" value="' + theVal + '" default-value="' + params.label + '"/>');
                       $j(target).append(fieldEl);
                       break;

                   case 'Text Area':
                       var theVal = (params.lastKnownValue != '') ? params.lastKnownValue : params.label;
                       var theDefaultClass = (params.lastKnownValue != '') ? '' : ' ib-form-field-default';
                       fieldEl = $j('<textarea class="ib-form-field ib-form-field-textarea' + theDefaultClass + theRequiredClass + '" order="' + params.order + '" validate-type="' + params.validationType + '" lpid="' + params.id + '" name="f' + params.id + '" id="ib-form-element-' + params.id + '" value="' + theVal + '" default-value="' + params.label + '">' + theVal + '</textarea>');
                       $j(target).append(fieldEl);
                       break;

                   case 'Dropdown Box':
                       var ddHTML = '<select effect="up" class="ib-form-field ib-form-field-dropdown ib-form-field-dropdown-up' + theRequiredClass + '" order="' + params.order + '" validate-type="dropdown" lpid="' + params.id + '" name="ib-form-element-' + params.id + '" id="ib-form-element-' + params.id + '">';
                       ddHTML += '<option value="#">' + params.label + '</option>';
                       for (var i = 0; i < params.entry.length; i++) {
                           if (params.entry[i].displayValue.charAt(0) == '#') {
                               params.entry[i].displayValue = params.entry[i].displayValue.slice(1);
                               ddHTML += '<option value="' + params.entry[i].value + '" data-alt-url="technical-inquiry-redirect' + emclp.getDivisionForInsertion(true) + '">' + params.entry[i].displayValue + '</option>';
                           } else {
                               ddHTML += '<option value="' + params.entry[i].value + '">' + params.entry[i].displayValue + '</option>';
                           }
                       }
                       ddHTML += '</select>';
                       $j(target).append(ddHTML);
                       fieldEl = $j('#ib-form-element-' + params.id);
                       // js select box activation
                       $j(fieldEl).eq(0).selectbox({
                           effect: 'up'
                       });
                       var jsSelectEl = inboundBar.forms.getJSSelectFromHTMLSelect(fieldEl);
                       // copy some CSS classes back and forth between the select and SB versions
                       if (fieldEl.hasClass('ib-form-field-dropdown-up')) {
                           jsSelectEl.addClass('sbHolderUp');
                       }
                       jsSelectEl.attr('order', params.order);
                       // change event
                       if (typeof (params.onChange) != 'undefined') {
                           fieldEl.bind('change', params.onChange);
                       }

                       var fSize = parseInt($j(jsSelectEl).find('.sbSelector').css('font-size'));
                       while ($j(jsSelectEl).find('.sbSelector').height() > 20 && fSize > 10) {

                           fSize--;
                           $j(jsSelectEl).find('.sbSelector').css('font-size', fSize + 'px');
                       }
                       break;

                   default:
                       inboundBar.trace('IB2: Unimplemented form field type:');
                       inboundBar.trace(params);

               }

           },
           getJSSelectFromHTMLSelect: function (el) {
               return $j('#sbHolder_' + $j(el).attr('sb'));
           },
           getHTMLSelectFromJSSelect: function (el) {
               return $j('select[sb="' + $j(el).attr('id').replace('ib-form-element-', '') + '"]');
           },
           staggerLayout: function (formWrapperEl) {
               $j(formWrapperEl).find('input.ib-form-field,.sbHolder,.ib-button,.ib-form-field-textarea').each(function (ix, el) {

                   $j(el).removeClass('ib-form-field-right');
                   if (ix % 2) {
                       $j(el).addClass('ib-form-field-right');
                   }

               });
           },
           radio: {
               count: 0,
               init: function (ev) {
                   $j('.ib-form-field-radio-group').each(function (ix, el) {
                       inboundBar.forms.radio.create(el);
                   });
               },
               create: function (el) {
                   $j(el).attr('radio-group', inboundBar.forms.radio.count);
                   inboundBar.forms.radio.count++;
                   $j(el).find('.ib-form-field-radio').each(function (ix1, el1) {
                       $j(el1).attr('radio-group', inboundBar.forms.radio.count);
                       $j(el1).addClass('ib-form-field');
                       if (ix1 % 2) {
                           $j(el1).addClass('ib-form-field-right');
                       }
                       $j(el).click(inboundBar.forms.radio.click);
                       $j(el1).prepend('<div class="ib-form-field-radio-icon"></div>');
                   });
               },
               click: function (ev) {
                   var evEl = $j(ev.target).closest('.ib-form-field-radio');
                   var groupEl = evEl.closest('.ib-form-field-radio-group');
                   var oldVal = groupEl.attr('selected-value');
                   evEl.siblings('.ib-form-field-radio').removeClass('ib-form-field-radio-on');
                   evEl.addClass('ib-form-field-radio-on');
                   groupEl.attr('selected-value', evEl.attr('value'));
                   if (oldVal != groupEl.attr('selected-value')) {
                       groupEl.trigger('change');
                   }
               }
           }
       },
       // ERROR DISPLAY /////////////////////////////////////////////////////////////

       errors: {
           init: function () {
               $j('.ib-error-button').click(inboundBar.errors.close);
           },
           display: function (text) {
               inboundBar.errors.close();
               $j('.ib-error-popup .ib-error-notice').html(text);
               $j('.ib-error-popup').show();
           },
           close: function (force) {
               if (force === true || $j('.ib-error-button').attr('suppress-close') !== 'true') {
                   $j('.ib-error-popup .ib-error-notice').html('');
                   $j('.ib-error-popup').hide();
               }
           }
       },
       // SUB-SECTIONS

       contactSliderInits: {
           'sales-chat': function () {
               if (!inboundBar.chat.isInitted) {

                   inboundBar.spinner.create($j('.ib-contact-content-sales-chat'));

                   LazyLoad.js(['/etc/designs/uwaem/manifests/js/framework/inbound-bar2-chat.js'], function () {
                       if (!inboundBar.chat.moduleLoaded) {
                           inboundBar.errors.display(inboundBar.getTextPiece('ib-error-panel-loading'));
                           inboundBar.spinner.destroy($j('.ib-contact-content-sales-chat'));
                       }
                   });
               }
           },
           'support-chat': function () {
           },
           'request-quote': function () {
           },
           'email-us': function () {
           },
           'phone': function () {
           }
       },
       // UPDATE H3s (auto text size)

       fitText: function (which, inText) {
           $j(which).attr('style', '');

           $j(which).html(inText);
           var temp = parseInt($j(which).css('font-size'));
           while ($j(which).height() > 40 && temp >= 11) {
               $j(which).css({
                   fontSize: temp + 'px',
                   lineHeight: Math.ceil(temp * 1.2) + 'px',
                   fontWeight: (temp < 14) ? 'bold' : 'normal'
               });
               temp--;
           }
       },
       // CHAT
       chat: {
           isInitted: false
       }
   };

$j(window).load(function () {
    // delay to avoid conflicts with ??? -- some pages weren't getting the bar despite it working fine after initting manually
    setTimeout(inboundBar.init,500); //ARE WE SURE ABOUT THIS?
    //inboundBar.init();
});


// Lazy Loading AddThis for social share buttons
LazyLoad.js(['//s7.addthis.com/js/250/addthis_widget.js?pub=ra-4d70fb56582d1bec&domready=1'], function () {
    try { addthis.timer.load; } catch (e) {};
});


/* >>> End of inboundBar.js */


inboundBar.translations.template={
    'chat-header-agent-available': '     ',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': '     ',
    'chat-header-agent-not-available': '     ',
    'chat-label-chat-alt-lang': '     ',
    'chat-label-leave-message': '     ',
    'chat-label-send-message': '     ',
    'chat-header-no-agents': '     ',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': '     ',
    'ib-button-ok': '     ',
    'ib-chat-lang-dropdown': '     ',
    'ib-error-chat-general': '     ',
    'ib-error-chat-form-validation': '     ',
    'ib-error-panel-loading': '     ',
    'ib-chat-offline-success': '     ',
    'technical-inquiry-redirect': '     ',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': '     ',
    'chat-window-send': '     ',
    'chat-window-end': '     ',
    'chat-window-agent-typing': '     '
};


inboundBar.translations.en_US={
    'chat-header-agent-available': 'To chat with an EMC Sales Specialist, please complete the following and select Start Chat.',
    'chat-header-agent-available-iig': 'To chat with an IIG Sales Specialist, please complete the following and select Start Chat.',
    'chat-header-agent-available-rsa': 'To chat with an RSA Sales Specialist, please complete the following and select Start Chat.',
    'chat-label-start-chat': 'START CHAT',
    'chat-header-agent-not-available': 'No agent is currently available for English. You can chat in another language, or if you prefer, leave a text message and a Sales Specialist will respond within one business day.',
    'chat-label-chat-alt-lang': 'CHAT IN ANOTHER LANGUAGE',
    'chat-label-leave-message': 'LEAVE A MESSAGE',
    'chat-label-send-message': 'SEND MESSAGE',
    'chat-header-no-agents': 'Thank you for contacting EMC. We apologize that all agents are either offline or helping others right now. For Technical Support, please visit our Service Center. For Sales Inquiries, please fill in the form below for a response within one business day.',
    'chat-header-no-agents-iig': 'Thank you for contacting EMC IIG. We apologize that all agents are either offline or helping others right now. For Technical Support, please visit our Service Center. For Sales Inquiries, please fill in the form below for a response within one business day.',
    'chat-header-no-agents-rsa': 'Thank you for contacting RSA. We apologize that all agents are either offline or helping others right now. For Technical Support, please <a href="http://www.emc.com/support/rsa/index.htm" target="_blank">click here</a> or call 1-800-995-5095. For Sales Inquiries, please call 1-800-495-1095 (Option 1) or visit the Sales Contact page <a href="http://www.emc.com/contact/contact-us.htm" target="_blank">here</a>.',
    'general-all-fields-required': 'All fields are required unless indicated (*)',
    'ib-button-ok': 'OK',
    'ib-chat-lang-dropdown': 'Choose another language...',
    'ib-error-chat-general': 'Sorry, there has been a problem with chat.<br/>Please try again later.',
    'ib-error-chat-form-validation': 'Please check your entries and enter valid information for the highlighted fields.',
    'ib-error-panel-loading': 'There was an error loading this panel, please reload the page and try again.',
    'ib-chat-offline-success': 'Thank you for your request. A sales representative will be contacting you soon.',
    'technical-inquiry-redirect': '<p>Thank you for contacting EMC.</p><p>For your Technical Support Inquiry, please <a href="https://support.emc.com/servicecenter/contactEMC/" title="Visit EMC Online Support" target="_blank">Visit EMC Online Support directly via this link</a></p><p>Thank you for your interest in EMC.</p>',
    'technical-inquiry-redirect-iig': '<p>Thank you for contacting EMC.</p><p>For your Technical Support Inquiry, please <a href="https://support.emc.com/servicecenter/contactEMC/" title="Visit EMC Online Support" target="_blank">Visit EMC Online Support directly via this link</a></p><p>Thank you for your interest in EMC.</p>',
    'technical-inquiry-redirect-rsa': '<p>For Technical Support, please <a href="http://www.emc.com/support/rsa/index.htm">visit Customer Support</a> or call 1-800-995-5095</p><p>Thank you for your interest in EMC.</p>',
    'chat-window-live-chat': 'LIVE CHAT',
    'chat-window-send': 'SEND',
    'chat-window-end': 'END CHAT',
    'chat-window-agent-typing': 'Agent is typing...'
};

inboundBar.translations.de_DE={
    'chat-header-agent-available': 'Wenn Sie mit einem EMC Vertriebsmitarbeiter sprechen möchten, machen Sie die folgenden Angaben und wählen Sie „Chat starten“ aus.',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': 'CHAT STARTEN',
    'chat-header-agent-not-available': 'Momentan ist kein Support für Deutsch verfügbar. Sie können entweder in einer anderen Sprache chatten oder eine Nachricht für einen Sales Specialist hinterlassen. Wir melden uns dann innerhalb eines Geschäftstags bei Ihnen.',
    'chat-label-chat-alt-lang': 'IN ANDERER SPRACHE CHATTEN',
    'chat-label-leave-message': 'NACHRICHT HINTERLASSEN',
    'chat-label-send-message': 'NACHRICHT SENDEN',
    'chat-header-no-agents': 'Danke, dass Sie sich an EMC gewandt haben. Leider sind gerade alle Mitarbeiter offline oder befinden sich im Gespräch mit anderen Kunden. Besuchen Sie für technischen Support unser Servicecenter. Füllen Sie für Sales-Anfragen das unten stehende Formular aus. Wir melden uns dann innerhalb eines Geschäftstags bei Ihnen.',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': 'Alle Felder sind Pflichtfelder, soweit nicht anders angegeben. (*)',
    'ib-button-ok': 'OK',
    'ib-chat-lang-dropdown': 'Andere Sprache wählen ...',
    'ib-error-chat-general': 'Es ist ein Problem mit dem Chat aufgetreten. Versuchen Sie es später erneut.',
    'ib-error-chat-form-validation': 'Bitte prüfen Sie Ihre Einträge und geben Sie gültige Informationen in die markierten Felder ein.',
    'ib-error-panel-loading': 'Beim Laden des Panels ist ein Problem aufgetreten. Laden Sie die Seite noch einmal und versuchen Sie es erneut.',
    'ib-chat-offline-success': 'Vielen Dank für Ihre Anfrage! Einer unserer Vertriebsmitarbeiter wird in Kürze Kontakt mit Ihnen aufnehmen.',
    'technical-inquiry-redirect': '<p>Danke, dass Sie sich an EMC gewandt haben. Sie haben angegeben, dass Sie technischen Support benötigen. Sie können unser Support-Team über den folgenden Link kontaktieren</p><p>Bei technischen Fragen besuchen Sie <a href="https://support.emc.com/servicecenter/contactEMC/?siteLocale=de_DE" title=" Besuchen Sie den EMC Online-Support" target="_blank">Klicken Sie auf diesen Link, um direkt zum EMC Online-Support zu gelangen.</a></p><p>Danke für Ihr Interesse an EMC.</p>',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': 'LIVE-CHAT',
    'chat-window-send': 'SENDEN',
    'chat-window-end': 'CHAT BEENDEN',
    'chat-window-agent-typing': 'Mitarbeiter tippt gerade eine Nachricht…'
};

inboundBar.translations.fr_FR={
    'chat-header-agent-available': 'Pour communiquer avec un spécialiste des ventes EMC, fournissez les informations suivantes, puis cliquez sur Démarrer le chat.',
    'chat-label-start-chat': 'DÉMARRER LE CHAT',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-header-agent-not-available': 'Aucun agent n&#0146;est actuellement disponible pour le français. Vous pouvez communiquer dans une autre langue, ou laisser un message textuel afin qu&#0146;un commercial vous réponde dans les 24 heures.',
    'chat-label-chat-alt-lang': 'COMMUNIQUER DANS UNE AUTRE LANGUE',
    'chat-label-leave-message': 'LAISSER UN MESSAGE',
    'chat-label-send-message': 'ENVOYER UN MESSAGE',
    'chat-header-no-agents': 'Merci d’avoir contacté EMC. Tous nos agents sont actuellement hors ligne ou occupés à aider d’autres clients. Pour accéder au support technique, rendez-vous dans notre Centre de services. Pour toute demande d’ordre commercial, veuillez remplir le formulaire ci-dessous et nous vous répondrons dans les 24 heures.',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': 'Tous les champs sont obligatoires sauf mention contraire (*)',
    'ib-button-ok': 'OK',
    'ib-chat-lang-dropdown': 'Sélectionnez une autre langue...',
    'ib-error-chat-general': 'Désolé, il y a eu un problème avec le chat. Veuillez réessayer ultérieurement.',
    'ib-error-chat-form-validation': 'Veuillez vérifier les valeurs saisies et renseigner des informations valides dans les champs en surbrillance.',
    'ib-error-panel-loading': 'Une erreur s’est produite lors du changement de cette section, veuillez recharger cette page et essayer de nouveau',
    'ib-chat-offline-success': 'Merci de votre demande. Un représentant commercial vous contactera rapidement.',
    'technical-inquiry-redirect': '<p>Merci d’avoir contacté EMC. Vous avez indiqué avoir besoin d&#0146;un support technique. Notre équipe de support est disponible au lien suivant</p><p>Pour obtenir une réponse à votre problème technique, rendez-vous sur <a href="https://support.emc.com/servicecenter/contactEMC/?siteLocale=fr_FR" title=" Rendez-vous sur le site du Support en ligne d’EMC " target="_blank">Rendez-vous directement sur le site du Support en ligne d’EMC en cliquant sur ce lien</a></p><p>Nous vous remercions de l’intérêt que vous portez à EMC.',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': 'CHAT EN DIRECT',
    'chat-window-send': 'ENVOYER',
    'chat-window-end': 'FIN CHAT',
    'chat-window-agent-typing': 'L’agent est en train d’écrire…'
};

inboundBar.translations.zh_CN={
    'chat-header-agent-available': '若要与 EMC 销售专家聊天，请填写下面的信息并选择“开始聊天”。',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': '开始聊天',
    'chat-header-agent-not-available': '当前没有中文销售工程师。 您可以使用其他语言聊天，或者如果您喜欢，可以留言，我们的销售工程师会在一个工作日内回复。',
    'chat-label-chat-alt-lang': '用其他语言聊天',
    'chat-label-leave-message': '留言',
    'chat-label-send-message': '发送留言',
    'chat-header-no-agents': '感谢您与 EMC 联系。 很抱歉，目前所有销售工程师或者离线或者正在帮助其他人。 对于技术支持，请访问我们的服务中心。 有关销售查询，请填写下面的表单，我们将在一个工作日内进行答复。',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': '除非另有说明，所有表项都需要填写。 (*)',
    'ib-button-ok': '好',
    'ib-chat-lang-dropdown': '请选择其他语言...',
    'ib-error-chat-general': '很抱歉，聊天程序有些问题。 请稍后重试。',
    'ib-error-chat-form-validation': '请检查您的条目并对高亮字段输入有效信息。',
    'ib-error-panel-loading': '加载这个窗格出错，请重新加载这个页面再试。',
    'ib-chat-offline-success': '谢谢您抽出宝贵时间参加本次演示。很快将有一名销售代表与您联系.',
    'technical-inquiry-redirect': '<p>感谢您与 EMC 联系。您已表明您需要技术支持。您可以通过以下链接与我们的支持团队联系</p><p>有关技术查询，请通过此链接<a href="https://support.emc.com/servicecenter/contactEMC/" title="访问 EMC 在线支持" target="_blank">直接访问 EMC 在线支持.</a></p><p>感谢您对 EMC 的关注</p>',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': '实时聊天',
    'chat-window-send': '发送',
    'chat-window-end': '结束聊天',
    'chat-window-agent-typing': '代理正在打字...'
};

inboundBar.translations.pt_BR={
    'chat-header-agent-available': 'Para entrar em um bate-papo on-line com um especialista de vendas da EMC, preencha abaixo e selecione Iniciar bate-papo.',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': 'INICIAR BATE-PAPO',
    'chat-header-agent-not-available': 'Nenhum agente está disponível para o idioma português. Você pode participar do bate-papo em outro idioma, ou se preferir, deixar uma mensagem de texto para que um especialista da equipe de vendas entre em contato com você, dentro de um dia útil.',
    'chat-label-chat-alt-lang': 'PARTICIPAR DE BATE-PAPO EM OUTRO IDIOMA',
    'chat-label-leave-message': 'DEIXAR UMA MENSAGEM',
    'chat-label-send-message': 'ENVIAR MENSAGEM',
    'chat-header-no-agents': 'Obrigado por entrar em contato com a EMC. Lamentamos, mas todos os agentes estão off-line ou ocupados no momento. Se precisar de suporte técnico, visite nosso Centro de Serviços. Para dúvidas relacionadas a vendas, preencha o formulário abaixo e receba um retorno dentro de um dia útil.',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': 'Todos os campos são obrigatórios, a menos que indicado o contrário (*)',
    'ib-button-ok': 'Ok',
    'ib-chat-lang-dropdown': 'Escolha um outro idioma...',
    'ib-error-chat-general': 'Infelizmente houve um problema com o bate-papo. Tente novamente mais tarde.',
    'ib-error-chat-form-validation': 'Verifique suas informações e forneça dados válidos nos campos em destaque.',
    'ib-error-panel-loading': 'Houve um erro ao carregar este painel. Recarregue a página e tente novamente.',
    'ib-chat-offline-success': 'Obrigado por sua solicitação. Um representante de vendas entrará em contato em breve.',
    'technical-inquiry-redirect': '<p>Obrigado por entrar em contato com a EMC. Indicou que está a procurar suporte técnico. A nossa equipa de suporte está disponível através da hiperligação seguinte</p><p>Para a nossa consulta técnica, visite <a href="https://support.emc.com/servicecenter/contactEMC/" title="Visit EMC Online Support" target="_blank">o suporte online da EMC diretamente através desta hiperligação.</a></p><p>Obrigado por seu interesse na EMC.</p>',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': 'BATE-PAPO',
    'chat-window-send': 'ENVIAR',
    'chat-window-end': 'FECHAR',
    'chat-window-agent-typing': 'O agente está a escrever...'
};

inboundBar.translations.pt_PT={
    'chat-header-agent-available': 'Para conversar com um especialista de vendas da EMC, preencha abaixo e selecione Iniciar chat.',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': 'INICIAR CHAT',
    'chat-header-agent-not-available': 'Nenhum agente está atualmente disponível para o idioma português. Você pode conversar em outro idioma, ou se preferir, deixe uma mensagem de texto e um especialista de vendas responderá dentro de um dia útil.',
    'chat-label-chat-alt-lang': 'PARTICIPAR DE CHAT EM OUTRO IDIOMA',
    'chat-label-leave-message': 'DEIXAR UMA MENSAGEM',
    'chat-label-send-message': 'ENVIAR UMA MENSAGEM',
    'chat-header-no-agents': 'Obrigado por entrar em contato com a EMC. Nossos atendentes se encontram ocupados neste momento. Para obter assistência técnica, visite o nosso Centro de Serviços. Para questões de vendas, por favor preencha o formulário abaixo para uma resposta no prazo de um dia útil.',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': 'Todos os campos são obrigatórios, a menos que indicado o contrário (*)',
    'ib-button-ok': 'OK',
    'ib-chat-lang-dropdown': 'Escolha outro idioma...',
    'ib-error-chat-general': 'Infelizmente houve um problema com o chat. Tente novamente mais tarde.',
    'ib-error-chat-form-validation': 'Verifique as informações e adicione dados válidos nos campos destacados.',
    'ib-error-panel-loading': 'Houve um erro ao carregar este painel. Recarregue a página e tente novamente.',
    'ib-chat-offline-success': 'Obrigado por sua solicitação. Um representante de vendas entrará em contato em breve.',
    'technical-inquiry-redirect': '<p>Obrigado por entrar em contato com a EMC. Você indicou que está buscando suporte técnico. Nossa equipe de suporte técnico está disponível no seguinte link</p><p>Para enviar sua consulta técnica, acesse <a href="https://support.emc.com/servicecenter/contactEMC/" title="Visit EMC Online Support" target="_blank">o Suporte on-line da EMC diretamente neste link.</a></p><p>Obrigado por seu interesse na EMC.</p>',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': 'BATE-PAPO',
    'chat-window-send': 'ENVIAR',
    'chat-window-end': 'FECHAR',
    'chat-window-agent-typing': 'O agente está a escrever...'
};

inboundBar.translations.es_MX={
    'chat-header-agent-available': 'Para chatear con un especialista de ventas de EMC, complete el siguiente formulario y seleccione Iniciar chat.',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': 'INICIAR CHAT',
    'chat-header-agent-not-available': 'En estos momentos no hay ningún agente disponible que le pueda atender en español. Puede chatear en otro idioma o, si lo prefiere, dejar un mensaje de texto y un especialista en ventas le responderá en el transcurso de un día laborable.',
    'chat-label-chat-alt-lang': 'CHATEAR EN OTRO IDIOMA',
    'chat-label-leave-message': 'DEJAR UN MENSAJE',
    'chat-label-send-message': 'ENVIAR MENSAJE',
    'chat-header-no-agents': 'Gracias por ponerse en contacto con EMC. Sentimos comunicarle que todos nuestros agentes están desconectados o ayudando a otros usuarios. Para obtener asistencia técnica, visite nuestro Centro de servicios. Para consultas sobre ventas, rellene el siguiente formulario y obtendrá respuesta en el plazo de un día laborable.',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': 'Todos los campos son obligatorios a menos que se indique lo contrario (*)',
    'ib-button-ok': 'Aceptar',
    'ib-chat-lang-dropdown': 'Elegir otro idioma…',
    'ib-error-chat-general': 'Lo sentimos, ha habido un problema con el chat. Vuelva a intentarlo más tarde.',
    'ib-error-chat-form-validation': 'Revise los campos resaltados y corríjalos con información válida.',
    'ib-error-panel-loading': 'Hubo un error al cargar este panel. Vuelva a cargar la página e inténtelo de nuevo.',
    'ib-chat-offline-success': 'Gracias por su solicitud. Un representante de ventas se pondrá en contacto con usted a la brevedad.',
    'technical-inquiry-redirect': '<p>Gracias por comunicarse con EMC. Indicó que busca soporte técnico. Nuestro equipo de soporte técnico está disponible por medio del siguiente enlace</p><p>Para realizar una consulta técnica, <a href="https://support.emc.com/servicecenter/contactEMC/" title="Visit EMC Online Support" target="_blank">Visite el servicio de soporte en línea de EMC directamente por medio de este enlace.</a></p><p>Gracias por su interés en EMC.</p>',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': 'CHAT EN VIVIO',
    'chat-window-send': 'ENVIAR',
    'chat-window-end': 'CERRAR',
    'chat-window-agent-typing': 'El agente está escribiendo...'
};

inboundBar.translations.es_ES={
    'chat-header-agent-available': 'Para chatear con un especialista de ventas de EMC, complete el siguiente formulario y seleccione Iniciar chat.',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': 'INICIAR CHAT',
    'chat-header-agent-not-available': 'En estos momentos no hay ningún agente disponible que le pueda atender en español .  Puede chatear en otro idioma o, si lo prefiere, dejar un mensaje de texto y un especialista en ventas le responderá en el transcurso de un día laborable.',
    'chat-label-chat-alt-lang': 'CHATEAR EN OTRO IDIOMA',
    'chat-label-leave-message': 'DEJAR UN MENSAJE',
    'chat-label-send-message': 'ENVIAR MENSAJE',
    'chat-header-no-agents': 'Gracias por ponerse en contacto con EMC. Sentimos comunicarle que todos nuestros agentes están desconectados o ayudando a otros usuarios. Para obtener asistencia técnica, visite nuestro Centro de servicios. Para consultas sobre ventas, rellene el siguiente formulario y obtendrá respuesta en el plazo de un día laborable.',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': 'Todos los campos son obligatorios a menos que se indique lo contrario (*)',
    'ib-button-ok': 'Aceptar',
    'ib-chat-lang-dropdown': 'Elegir otro idioma…',
    'ib-error-chat-general': 'Lo sentimos, ha habido un problema con el chat. Vuelva a intentarlo más tarde.',
    'ib-error-chat-form-validation': 'Revise los campos resaltados y corríjalos con información válida.',
    'ib-error-panel-loading': 'Ha habido un error al cargar este panel. Vuelva a cargar la página e inténtelo de nuevo.',
    'ib-chat-offline-success': 'Gracias por su solicitud. Un representante de ventas se pondrá en contacto con usted a la brevedad.',
    'technical-inquiry-redirect': '<p>Gracias por ponerse en contacto con EMC. Ha indicado que busca soporte técnico. Nuestro equipo de soporte técnico está disponible por medio del siguiente enlace</p><p>Para realizar una consulta técnica,  <a href="https://support.emc.com/servicecenter/contactEMC/" title="Visit EMC Online Support" target="_blank">Visite el servicio de soporte en línea de EMC directamente por medio de este enlace.</a></p><p>Gracias por su interés en EMC.</p>',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': 'CHAT EN LíNEA',
    'chat-window-send': 'ENVIAR',
    'chat-window-end': 'CERRAR',
    'chat-window-agent-typing': 'El agente está escribiendo...'
};

inboundBar.translations.it_IT={
    'chat-header-agent-available': 'Per parlare in chat con un EMC Sales Specialist, compili il seguente modulo, quindi selezioni Avvia chat.',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': 'AVVIA CHAT',
    'chat-header-agent-not-available': 'Attualmente non sono presenti operatori in lingua italiana. Puoi scegliere di avviare la chat in un&#0146;altra lingua o, se preferisci, puoi lasciare un messaggio di testo e un Sales Specialist ti risponderà entro un giorno lavorativo.',
    'chat-label-chat-alt-lang': 'AVVIA CHAT IN UN’ALTRA LINGUA',
    'chat-label-leave-message': 'LASCIA UN MESSAGGIO',
    'chat-label-send-message': 'INVIA UN MESSAGGIO',
    'chat-header-no-agents': 'Grazie per aver contattato EMC. Ci scusiamo, ma al momento tutti gli operatori sono offline o impegnati a fornire assistenza ad altri utenti. Per ricevere supporto tecnico, visita il nostro Centro Assistenza.  Per domande sulle vendite, compila il modulo riportato di seguito e riceverai una risposta entro un giorno lavorativo.',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': 'Se non diversamente indicato, tutti i campi sono obbligatori (*)',
    'ib-button-ok': 'OK',
    'ib-chat-lang-dropdown': 'Seleziona un&#0146;altra lingua…',
    'ib-error-chat-general': 'Spiacenti, si è verificato un problema con la chat. Riprova più tardi.',
    'ib-error-chat-form-validation': 'Verifica i dati inseriti e immetti informazioni valide nei campi evidenziati.',
    'ib-error-panel-loading': 'Si è verificato un errore durante il caricamento di questo riquadro. Ricarica la pagina e riprova.',
    'ib-chat-offline-success': 'Grazie per la richiesta: un incaricato EMC se ne occuperà al più presto.',
    'technical-inquiry-redirect': '<p>Grazie per aver contattato EMC. Ha indicato di aver bisogno di supporto tecnico. Il team del supporto tecnico EMC è disponibile al seguente link</p><p>Per richieste di carattere tecnico,<a href="https://support.emc.com/servicecenter/contactEMC/" title=" visiti direttamente il supporto online EMC" target="_blank">isiti direttamente il supporto online EMC utilizzando il seguente link.</a></p><p>Grazie dell&#0146;interesse dimostrato per EMC.</p>',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': 'LIVE CHAT',
    'chat-window-send': 'INVIA',
    'chat-window-end': 'CHIUDI',
    'chat-window-agent-typing': 'L&#0146;agente sta scrivendo...'
};

inboundBar.translations.ru_RU={
    'chat-header-agent-available': 'Чтобы поговорить в чате с менеджером по продажам EMC, заполните форму ниже и выберите «Начать чат».',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': 'НАЧАТЬ ЧАТ',
    'chat-header-agent-not-available': 'В настоящий момент все русскоязычные специалисты заняты. Вы можете пообщаться с нашими специалистами на другом языке или оставить текстовое сообщение. Специалист по продажам свяжется с вами в течение одного рабочего дня.',
    'chat-label-chat-alt-lang': 'ЧАТ НА ДРУГОМ ЯЗЫКЕ',
    'chat-label-leave-message': 'ОСТАВИТЬ СООБЩЕНИЕ',
    'chat-label-send-message': 'ОТПРАВИТЬ СООБЩЕНИЕ',
    'chat-header-no-agents': 'Спасибо, что связались с EMC. К сожалению, в настоящий момент все наши специалисты заняты или недоступны. Если вам необходима техническая поддержка, свяжитесь, пожалуйста, с Центром технической поддержки. Если ваш запрос связан с продажами, заполните, пожалуйста, форму ниже. Мы ответим вам в течение одного рабочего дня.',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': 'Все поля обязательны для заполнения (*)',
    'ib-button-ok': 'OK',
    'ib-chat-lang-dropdown': 'Выберите другой язык...',
    'ib-error-chat-general': 'С чатом возникли проблемы. Приносим свои извинения. Пожалуйста, повторите попытку позднее.',
    'ib-error-chat-form-validation': 'Пожалуйста, проверьте правильность указанных вами сведения и введите корректную информацию в указанные поля.',
    'ib-error-panel-loading': 'Загрузка прервана по причине ошибки. Пожалуйста, перезагрузите страницу и повторите попытку',
    'ib-chat-offline-success': 'Спасибо за запрос. Торговый представитель вскоре с Вами свяжется.',
    'technical-inquiry-redirect': '<p>Спасибо, что связались с EMC. Вы сообщили, что запрос касается технической поддержки. Перейдите по ссылке ниже, чтобы связаться с сотрудниками службы поддержки.</p><p>Приглашаем вас посетить <a href="https://support.emc.com/servicecenter/contactEMC/" title=" Центр онлайн-поддержки " target="_blank">Центр онлайн-поддержки</a></p><p>Спасибо за интерес к EMC.</p>',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': 'ПРЯМОЙ ЧАТ',
    'chat-window-send': 'ОТПРАВИТЬ',
    'chat-window-end': 'ЗАКОНЧИТЬ ЧАТ',
    'chat-window-agent-typing': 'Оператор печатает…'
};

inboundBar.translations.ja_JP={
    'chat-header-agent-available': '営業担当とのチャットを開始するには、必要事項をご入力いただき、『チャットを開始』ボタンをクリックしてください。',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': 'チャットを開始',
    'chat-header-agent-not-available': '現在、大変混みあっており、[英語]での対応が可能な担当者におつなぎできません。他の言語でチャットしていただくことも可能です。あるいはテキスト メッセージをお残しいただければ、営業担当者が1営業日以内にご連絡いたします。',
    'chat-label-chat-alt-lang': '他の言語でチャットする',
    'chat-label-leave-message': 'メッセージを残す',
    'chat-label-send-message': 'メッセージを送信',
    'chat-header-no-agents': 'EMCジャパンにお問合せいただきましてありがとうございます。大変申し訳ございませんが、担当者が不在もしくは別のチャット対応中でございます。テクニカルサポートに関するお問い合わせの方はEMCオンラインサポートにアクセスをお願い致します。営業に関するお問い合わせの方はご質問内容をご記入いただければ、翌営業日までに折り返しご連絡をさせていただきます。',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': '*がついている項目に必須事項を入力してください',
    'ib-button-ok': 'OK',
    'ib-chat-lang-dropdown': '別の言語を選択...',
    'ib-error-chat-general': '申し訳ありません。チャットに問題が発生しました。 しばらくしてから、再度お試しください。',
    'ib-error-chat-form-validation': '入力内容を確認し、ハイライト表示されたフィールドに有効な情報を入力してください。',
    'ib-error-panel-loading': 'このパネルのロード中にエラーが発生しました。ページを再ロードし、やり直してください',
    'ib-chat-offline-success': 'お問い合わせいただきありがとうございます。すぐに営業担当者よりご連絡差し上げます。',
    'technical-inquiry-redirect': '     ',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': 'ライブチャット',
    'chat-window-send': '送信',
    'chat-window-end': 'チャットを終了する',
    'chat-window-agent-typing': 'エージェントが入力しています…'
};

inboundBar.translations.ko_KR={
    'chat-header-agent-available': 'EMC 영업 담당자와 채팅하려면 다음 사항을 입력한 후 채팅 시작을 선택하십시오.',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': '채팅 시작',
    'chat-header-agent-not-available': '현재 한국어 구사 직원과 연결할 수 없습니다. 다른 언어로 채팅하시거나, 메시지를 남겨 주시면 영업 담당자가 업무일 기준 1일 이내에 답변해 드리겠습니다.',
    'chat-label-chat-alt-lang': '다른 언어로 채팅하기',
    'chat-label-leave-message': '메시지 남기기',
    'chat-label-send-message': '메시지 보내기',
    'chat-header-no-agents': 'EMC에 문의해주셔서 감사합니다. 현재 모든 직원이 오프라인 상태이거나 다른 문의 사항을 지원 중입니다. 기술 지원이 필요하신 경우 서비스 센터에 방문해 주십시오. 영업 관련 질문이 있는 경우 아래 양식을 작성해 주시면 업무일 기준 1일 이내에 답변해 드리겠습니다.',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': '달리 명시되지 않는 한 모든 필드에 정보를 입력해야 합니다. (*)',
    'ib-button-ok': '확인',
    'ib-chat-lang-dropdown': '다른 언어를 선택해 주십시오.',
    'ib-error-chat-general': '죄송합니다. 채팅에 문제가 발생했습니다. 나중에 다시 시도하십시오.',
    'ib-error-chat-form-validation': '입력 항목을 확인한 다음 강조 표시된 필드에 유효한 정보를 입력하십시오.',
    'ib-error-panel-loading': '이 패널을 로드하는 중에 오류가 발생했습니다. 페이지를 다시 로드해보시기 바랍니다.',
    'ib-chat-offline-success': '요청해 주셔서 감사합니다. 영업 담당자가 곧 연락 드리겠습니다.',
    'technical-inquiry-redirect': '     ',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': '     ',
    'chat-window-send': '     ',
    'chat-window-end': '     ',
    'chat-window-agent-typing': '     '
};

inboundBar.translations.pl_PL={
    'chat-header-agent-available': 'Aby porozmawiać ze sprzedawcą z EMC, wprowadź informacje poniżej, a następnie kliknij przycisk Rozpocznij czat.',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': 'ROZPOCZNIJ CZAT',
    'chat-header-agent-not-available': 'Żaden ze sprzedawców posługujących się wybranym przez Ciebie językiem (polskim) nie jest obecnie dostępny. Możesz porozmawiać w innym języku albo zostawić wiadomość tekstową, a sprzedawca skontaktuje się z Tobą w ciągu jednego dnia roboczego.',
    'chat-label-chat-alt-lang': 'ROZPOCZNIJ CZAT W INNYM JĘZYKU',
    'chat-label-leave-message': 'ZOSTAW WIADOMOŚĆ',
    'chat-label-send-message': 'WYŚLIJ WIADOMOŚĆ',
    'chat-header-no-agents': 'Dziękujemy za nawiązanie kontaktu z firmą EMC. Niestety obecnie wszyscy sprzedawcy są niedostępni lub zajęci rozmową z innymi klientami. Jeśli potrzebujesz pomocy technicznej, skorzystaj z centrum pomocy. W przypadku pytań dotyczących sprzedaży wypełnij poniższy formularz, a sprzedawca skontaktuje się z Tobą w ciągu jednego dnia roboczego.',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': 'Wszystkie pola są wymagane (chyba że wskazano inaczej) (*)',
    'ib-button-ok': 'OK',
    'ib-chat-lang-dropdown': 'Wybierz inny język…',
    'ib-error-chat-general': 'Przepraszamy, wystąpił problem z czatem. Spróbuj ponownie później.',
    'ib-error-chat-form-validation': 'Sprawdź wpisane informacje i wprowadź poprawne dane w podświetlonych polach.',
    'ib-error-panel-loading': 'Wystąpił problem podczas ładowania panelu. Ponownie załaduj stronę i spróbuj jeszcze raz.',
    'ib-chat-offline-success': 'Dziękujemy za przesłanie zgłoszenia. Przedstawiciel handlowy wkrótce się z Panem/Panią skontaktuje.',
    'technical-inquiry-redirect': '<p>Dziękujemy za kontakt z EMC. W formularzu zaznaczono opcję wsparcia technicznego.</p><p>Nasz zespół jest dostępny pod następującym adresem:<a href="https://support.emc.com/servicecenter/contactEMC/" title="Dział internetowej pomocy technicznej EMC" target="_blank">Dział internetowej pomocy technicznej EMC</a></p><p>Dziękujemy za zainteresowanie ofertą EMC.</p>',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': 'BEZPOŚREDNI CZAT',
    'chat-window-send': 'WYŚLIJ',
    'chat-window-end': 'ZAKOŃCZ CZAT',
    'chat-window-agent-typing': 'Przedstawiciel pisze...'
};

inboundBar.translations.cs_CZ={
    'chat-header-agent-available': 'Chcete-li se spojit prostřednictvím chatu s prodejním specialistou společnosti EMC, vyplňte následující údaje a klikněte na tlačítko Zahájit chat.',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': 'ZAHÁJIT CHAT',
    'chat-header-agent-not-available': 'V tuto chvíli není k dispozici žádný česky hovořící operátor. Můžete zahájit chat v jiném jazyce, nebo zanechat textovou zprávu. Prodejní specialista vám do jednoho pracovního dne odpoví.',
    'chat-label-chat-alt-lang': 'CHAT V JINÉM JAZYCE',
    'chat-label-leave-message': 'ZANECHAT ZPRÁVU',
    'chat-label-send-message': 'ODESLAT ZPRÁVU',
    'chat-header-no-agents': 'Děkujeme, že jste se obrátili na společnost EMC. Je nám líto, ale všichni naši operátoři jsou buď odpojení, nebo právě pomáhají někomu jinému. Potřebujete-li technickou podporu, navštivte naše centrum služeb. Máte-li dotaz týkající se prodeje, vyplňte níže uvedený formulář a my vám do jednoho pracovního dne odpovíme.',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': 'Není-li uvedeno jinak, je potřeba vyplnit všechna pole. (*)',
    'ib-button-ok': 'OK',
    'ib-chat-lang-dropdown': 'Vyberte jiný jazyk…',
    'ib-error-chat-general': 'Omlouváme se, ale vyskytl se problém s chatem. Zkuste to znovu později.',
    'ib-error-chat-form-validation': 'Zkontrolujte zadané údaje a vložte platné informace do zvýrazněných polí.',
    'ib-error-panel-loading': 'Během načítání tohoto panelu došlo k potížím. Načtěte stránku znovu a pokus opakujte.',
    'ib-chat-offline-success': 'Děkujeme za váš požadavek. Brzy vás bude kontaktovat obchodní zástupce.',
    'technical-inquiry-redirect': '<p>Děkujeme vám, že jste kontaktovali společnost EMC. Označili jste, že požadujete technickou podporu.</p><p>Na náš tým podpory se můžete obrátit prostřednictvím následujícího odkazu:<a href="https://support.emc.com/servicecenter/contactEMC/" title="Podpora EMC Online" target="_blank">Podpora EMC Online</a></p><p>Děkujeme vám za váš zájem o společnost EMC.</p>',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': 'PŘÍMÝ CHAT',
    'chat-window-send': 'ODESLAT',
    'chat-window-end': 'SKONČIT CHAT',
    'chat-window-agent-typing': 'Operátor píše zprávu…'
};

inboundBar.translations.tr_TR={
    'chat-header-agent-available': 'Bir EMC Satış Uzmanıyla sohbete başlatmak için lütfen aşağıdakileri doldurun ve Sohbeti Başlat’ı seçin.',
    'chat-header-agent-available-iig': '     ',
    'chat-header-agent-available-rsa': '     ',
    'chat-label-start-chat': 'SOHBETİ BAŞLAT',
    'chat-header-agent-not-available': 'Şu anda Türkçe için  temsilci yok. Başka bir dilde sohbet edebilirsiniz veya dilerseniz mesaj bırakıp Satış Uzmanı&#0146;nın bir iş günü içinde size geri dönmesini bekleyebilirsiniz.',
    'chat-label-chat-alt-lang': 'BAŞKA BİR DİLDE SOHBET ET',
    'chat-label-leave-message': 'MESAJ BIRAK',
    'chat-label-send-message': 'MESAJ GÖNDER',
    'chat-header-no-agents': 'EMC ile iletişim kurduğunuz için teşekkür ederiz. Ne yazık ki şu anda tüm temsilciler çevrimdışı veya başka bir kişiye yardımcı oluyor. Teknik Destek için lütfen Hizmet Merkezimizi ziyaret edin. Satışla İlgili Sorularınız için lütfen bir iş günü içinde yanıt almak üzere aşağıdaki formu doldurun.',
    'chat-header-no-agents-iig': '     ',
    'chat-header-no-agents-rsa': '     ',
    'general-all-fields-required': 'Aksi belirtilmedikçe tüm alanların doldurulması zorunludur (*)',
    'ib-button-ok': 'Tamam',
    'ib-chat-lang-dropdown': 'Başka bir dil seçin…',
    'ib-error-chat-general': 'Üzgünüz, sohbetle ilgili bir hata oluştu. Lütfen daha sonra tekrar deneyin.',
    'ib-error-chat-form-validation': 'Lütfen bilgilerinizi kontrol edin ve vurgulanan alanlara geçerli bilgiler girin.',
    'ib-error-panel-loading': 'Bu paneli yüklerken bir hata oluştu. Lütfen sayfayı tekrar yükleyin ve yeniden deneyin.',
    'ib-chat-offline-success': 'Talebiniz için teşekkür ederiz. Bir satış temsilcisi kısa süre içinde sizinle iletişime geçecektir.',
    'technical-inquiry-redirect': '<p>EMC ile iletişim kurduğunuz için teşekkür ederiz. Teknik destek talep ettiğinizi belirttiniz.</p><p>Destek ekibimize aşağıdaki linkten ulaşabilirsiniz: <a href="https://support.emc.com/servicecenter/contactEMC/" title="EMC Online Destek" target="_blank">EMC Online Destek</a></p><p>EMC&#0146;ye ilginize teşekkür ederiz.</p>',
    'technical-inquiry-redirect-iig': '     ',
    'technical-inquiry-redirect-rsa': '     ',
    'chat-window-live-chat': 'CANLI SOHBET',
    'chat-window-send': 'GÖNDER',
    'chat-window-end': 'SOHBET BITIR',
    'chat-window-agent-typing': 'Temsilci yazıyor...'
};

/* emc-bodyinject.js */
// For document.write script calls for bottom of BODY
UW.util.docWrite([
    // "//use.typekit.net/fmn1ayd.js"
]);

// File: components-loader.js
// Description: 
// Dependency: _util.js / _homepage.js

(function ($) {
    'use strict';
    window.UW = window.UW || {};
    
    // Generic Adaptive/Responsive Image Replacement call.
    $(function () {
	    UW.util.image.srcSet('.img-srcset');

        if($('[data-implement="slider"]').length){    
            UW.util.loader.js(["/etc/designs/uwaem/manifests/js/components/widget-slider.js"],function(){
                $('[data-implement="slider"]').uwSlider();
            });
        }
        
        if($('.uw-selector').length){    
            UW.util.loader.js(["/etc/designs/uwaem/manifests/js/components/widget-selector.js"],function(){
                $('.uw-selector').uwSelector();
            });
        }
        
        if($('.homepage-view').length){    
            // need to find out a solution for the peekaboo hiding text
            //UW.homepage.displayNextElement(".homepage .homepage-view .picture", {elementMinHeight: 542});
        }
        
    });
    
})(jQuery);
/* 
 * child-category-filter.js
 * dependencies: jQuery 1.10
 */
(function ($) {
    'use strict';

    UW.util.namespace('UW.childCategoryFilter');

    UW = UW.util.extend(UW, {
        /*
         * util: filter and show only a set of nodes based on a criteria
         * use: invoke module on page load, eg: UW.childCategoryFilter.init(jQuery);
         */
        childCategoryFilter: (function () {

            var props = {
                teasers: {
                    all: null
                },
                inited: false,
                filters: [],
                seeMore: false,
                descriptions: null,
                holder: '.recap-view',
                maxVisibleTiles: null,
                currentCategory: 'all', //by default, all the tiles are shown
                transitionTime: 500, //default
                seeMorebutton: null,
                teasersContainer: null,
                name: 'session-recap',
                expanded: [],
                ie8: !!Modernizr.ie && Modernizr.ie < 9
            },
            methods = {};

            /*methods running on click event:*/

            //returns just tiles matching a category
            methods.getFilteredTeasers = function (category) {
                category = category || '';

                if (!category || category === props.currentCategory || !props.teasers.hasOwnProperty(category)) {
                    //missing category parameter, no-hash in the URL, or asked filter that is already applied. So exit
                    return false;
                } else {
                    //hide all the tiles, we need to reinsert them without any reference 
                    //so the browser calculates again the right margins for the new set
                    props.teasersContainer.empty();

                    //update status
                    props.currentCategory = category;

                    //update UI
                    methods.renderUpdatedUI(category);
                }

            };

            methods.renderUpdatedUI = function (category) {
                //animate showing of selected tiles & descriptions
                methods.showTeasers(category);
                methods.showDescription(category);
            };

            //show new set of tiles into the DOM
            methods.showTeasers = function (category) {

                //cases:
                //see more clicked: iterate from Fixed limit to last array item (e.g.: 12-18)
                //see more already clicked: iterate from 0 to last array item (e.g.: 0-18)
                //see new set of teaser: iterate from 0 to Fixed limit (e.g.: 0-12)

                var isAlreadyExpanded = methods.isAlreadyExpanded(category),
                    limit = props.seeMore || isAlreadyExpanded ? props.teasers[category].length : props.maxVisibleTiles;


                //init process for new array of tiles or just animate existent ones
                methods.insertTeasers(category, limit).then(function () {
                    
                    return methods.ie8FixRightMargin();
                    
                }).then(function () {
                    //show-animate hidden teasers
                    return methods.fadeIn(limit, category);
                }).done(function () {
                    //evaluate See More button
                    return methods.setSeeMoreButtonStatus(category, limit);
                });

            };

            //insert the whole block of <li>
            methods.insertTeasers = function (category, limit) {
                limit = limit || props.maxVisibleTiles;
                var deferred = new $.Deferred();

                //accesing just one time the DOM
                $(props.teasersContainer).html($(props.teasers[category]).slice(0, limit).addClass('hidden transparent'));

                deferred.resolve();
                return deferred.promise();

            };

            //animate opacity 
            methods.fadeIn = function (limit, category) {
                limit = limit || props.maxVisibleTiles;

                $(props.teasers[category])
                    .slice(0, limit)
                    .removeClass('hidden') //return it to DOM but invisible
                    .animate({opacity: 1}, props.transitionTime, function () { //progressive dispalying
                        $(this).removeClass('transparent') //it isn't useful now
                            .css('opacity', ''); //reset state for further animations
                    });

            };

            //show or hide see more button
            methods.setSeeMoreButtonStatus = function (category, limit) {

                //get button from DOM, just the first time
                props.seeMorebutton = props.seeMorebutton === null ? $(props.holder + ' .see-more') : props.seeMorebutton;

                if (props.teasers[category].length > limit) { //set of tiles is greater than limit    
                    props.seeMorebutton.removeClass('hidden'); //show button, some will be hidden
                } else { //more tiles than the limit to show
                    props.seeMorebutton.addClass('hidden'); //don't show button
                    props.seeMore = false; //reset status
                }

            };

            methods.showDescription = function (category) {

                props.descriptions.filter('.active').removeClass('active'); //first ensure they all are hidden      

                props.descriptions.filter('[data-category="' + category + '"]')
                    .css('opacity', 0)
                    .addClass('active') //virtually in DOM but invisible
                    .animate({opacity: 1}, props.transitionTime, function () { //turn it visible
                        $(this).css('opacity', ''); //reset state for further animations
                    });

            };

            /*Methods running on init:*/

            //bind click event to menu options
            methods.applyBindings = function () {
                var deferred = new $.Deferred();

                $( props.holder ).on('click.recap.filtering', '.filters a', function (e) {

                    e.preventDefault();

                    var data = $(this).data(),
                        category = data.category;

                    //add hash to URL
                    UW.util.hash.set(props.name, category);

                    //start filtering process
                    methods.getFilteredTeasers(category);

                }).on('click.recap.seeMore', ' .see-more', function () {

                    props.seeMore = true; //activate see-more process


                    if (!methods.isAlreadyExpanded(props.currentCategory)) { //wasn't expanded yet? (== !false)
                        //if category is not already in the model, set it to track teasers already expanded
                        props.expanded.push(props.currentCategory);
                    }

                    methods.showTeasers(props.currentCategory); //pass as parameter the category used

                });

                deferred.resolve();

                return deferred.promise();
            };

            //Check if category is already saved on the model. return Boolean. 
            methods.isAlreadyExpanded = function (category) {

                return ($.inArray(category, props.expanded) === -1) ? false : true;

            };

            //get filters from the DOM and store them
            methods.getFilters = function () {
                var deferred = new $.Deferred();

                //get every filter
                props.filters = $(props.holder + ' .filters a');

                deferred.resolve();

                return deferred.promise();
            };

            //get tiles from the DOM and store them
            methods.getTeasers = function () {
                var deferred = new $.Deferred();

                //get every teaser
                props.teasers.all = $(props.holder + ' .teasers li').clone().removeClass('hidden transparent');

                //evaluate see more button on page load - show/hide
                methods.setSeeMoreButtonStatus(props.currentCategory, props.maxVisibleTiles);

                if (props.teasers.all.length !== 0) {
                    deferred.resolve(); //we've an actual set of teasers to work on
                } else {
                    deferred.reject();
                }

                return deferred.promise();
            };

            //hash initial teasers based on their category
            methods.mapTeasers = function () {
                var deferred = new $.Deferred(),
                    len = props.teasers.all.length,
                    i = 0;

                //get category for each teaser and set based on it, in the right array    
                for (i; i < len; i++) {
                    var data = $(props.teasers.all[i]).data();
                    methods.setCategories(data, props.teasers.all[i]);
                }

                deferred.resolve();

                return deferred.promise();
            };

            //insert new value or create new object property if it's new
            methods.setCategories = function (data, element) {

                if (!props.teasers.hasOwnProperty(data.category)) { //property does not exist
                    props.teasers[data.category] = [];
                }

                props.teasers[data.category].push(element);
            };

            //get descriptions from DOM and store them
            methods.getDescriptions = function () {
                var deferred = new $.Deferred();

                props.descriptions = $(props.holder + ' .descriptions li');

                deferred.resolve();

                return deferred.promise();
            };

            //use this to set any dynamic value on props 
            methods.setConfiguration = function () {
                var deferred = new $.Deferred();

                //get max number of teasers to show before press see more button
                props.maxVisibleTiles = Number($(props.holder + ' .teasers').attr('data-max-items')) || 12 //adding default;

                //get teaser container TODO: check if it's needed
                props.teasersContainer = $(props.holder + ' .teasers');

                deferred.resolve();

                return deferred.promise();
            };

            //Implement UW.util.hash
            //get hash on pageload and activate filtering
            methods.evaluateHash = function () {
                var deferred = new $.Deferred(),
                    category = UW.util.hash.get(props.name);

                methods.getFilteredTeasers(category);

                if (category) {
                    //change this when uw.selector library is completed
                    UW.util.loader.js(["/etc/designs/uwaem/manifests/js/components/widget-selector.js"], function () {
                        jQuery(props.holder + ' .uw-selector.filters-set').uwSelector();
                        jQuery(props.holder + ' .uw-selector.filters-set').uwSelector('selectItem', props.filters.filter('[data-category="' + category + '"]'));
                    });
                }

                deferred.resolve();
                return deferred.promise();
            };

            /**
             * After insertion force IE8 to nth-child(3n) have margin right 0
             * @returns {Object} Promise
             */
            methods.ie8FixRightMargin = function () {
                var deferred = new $.Deferred();

                if (props.ie8) {

                    setTimeout(function () {
                        $(props.holder + ' .teasers').find('li:nth-child(3n)').css('margin-right', '0')
                            .siblings(':not(li:nth-child(3n))').css('margin-right', '');
                        deferred.resolve();
                    }, 50);

                } else {
                    deferred.resolve();
                }

                return deferred.promise();
            };

            //fire module on page load
            methods.init = function () {

                if (!props.inited) {

                    props.inited = true;

                    methods.setConfiguration().then(function () {

                        return methods.getFilters();

                    }).then(function () {

                        return methods.getTeasers();

                    }).then(function () {

                        return methods.mapTeasers();

                    }).then(function () {

                        return methods.getDescriptions();

                    }).then(function () {

                        return methods.evaluateHash();

                    }).done(function () {

                        return methods.applyBindings();

                    }).fail(function () {

                    });

                }
            };

            return {
                init: methods.init
            };
        })()
    });

}(jQuery));

(function () {
    'use strict';
    UW.childCategoryFilter.init();
}());

// File: related-items.js
// Description: handle button heights
// Dependency: jquery

(function($) {

    'use strict';
    UW.util.namespace("UW.relatedItems");

    UW = UW.util.extend(UW, {
        relatedItems: (function() {

            return{
                properties: {
                    collection: $(".match-height")  //each element to equal its height, should have this class
                },
                init: function() {
                    //don't run if the component isn't in the page
                    if(!this.properties.collection.length) return false;
                    
                    this.setHeights();
                    var that = this;
                    //remove height if small/medium, set again if large > 
                    UW.breakpoint.addBreakpointChangeListener().then(function() {
                        $(window).on('breakpoint.changed', function(event, details) {
                            that.evaluateBreakpoint();
                        });
                    });

                },
                evaluateBreakpoint: function() {
                    var screenSize = UW.breakpoint.getScreenSize();

                    this.setHeights(screenSize);

                },
                setHeights: function(breakpoint) {
                    var i = this.properties.collection.length,
                            e = i,
                            s = 0;
                    //remove height if small or medium
                    if (breakpoint === "small" || breakpoint === "medium") {
                        while (i--) {
                            $(this.properties.collection[i]).attr('style','');
                        }
                        return false;
                    }
                    //if large, get max height
                    while (i--) {
                        s = $(this.properties.collection[i]).height() > s ? $(this.properties.collection[i]).height() : s;
                    }
                    //set the max height to every element
                    while (e--) {
                        $(this.properties.collection[e]).height(s);
                    }

                }
            };

        })()

    });
}(jQuery));

(function() {
    'use strict';
    UW.relatedItems.init();
})();


// File: _dtm.js
// Description: Adobe Dynamic Tag Manager bottom JS call
// Requirements: Implement just before the closing </body> tag
// Dependencies: //assets.adobedtm.com/81d0c75cc2c56ee7cbbb3de103fe1f7b442bb9a7/satelliteLib-c3c3c7ad9967d3bb40540600d09c43ef34628abc.js

// Check to make sure _satellite is defined in dependency code listed above before trying to execute
if (_satellite != undefined && _satellite != false) {
	_satellite.pageBottom();
}