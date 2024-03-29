/*
 * notifIt! by @naoxink
 */
(function(root, factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        define(factory);
    } else {
        // Browser globals
        var package = factory(root.b);
        root.notif = package.notif;
        root.notifit_dismiss = package.notifit_dismiss;
    }
}(this, function() {
    function notif(config) {
        // Util stuff
        var create_close_button = function() {
            return $('<span>', {
                'id': 'notifIt_close',
                'html': '&times'
            });
        }
        var create_notification = function() {
                var div = $('<div>', {
                    'id': 'ui_notifIt'
                });
                var p = $('<p>', {
                    html: defaults.msg
                });
                div.append(p);
                return div;
            }
            // Global timeout
        window.notifit_timeout = null;
        // We love jQuery
        var $ = jQuery;
        // Mid position
        var mid = (window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth) / 2;
        // Available positions
        var available_positions = ['left', 'center', 'right', 'bottom'];
        // Default config
        var defaults = {
            type: "default",
            width: 400,
            height: 60,
            position: "right",
            autohide: 1,
            msg: "This is my default message",
            opacity: 1,
            multiline: 0,
            fade: 0,
            bgcolor: "",
            color: "",
            timeout: 5000,
            zindex: null,
            offset: 0,
            callback: null,
            clickable: false,
            animation: 'slide',
            vertoffset: 10
        };
        // Extend with new params
        $.extend(defaults, config);
        // Animation config
        // ** Maybe create an external js with only animations for easier customizing? **
        defaults.animations = {}
        // Slide animation [DEFAULT]
        defaults.animations.slide = {
            'center': {
                'css_start': {
                    "top": parseInt(0 - (defaults.height + 10)),
                    "left": mid - parseInt(defaults.width / 2)
                },
                'in': {
                    'top': parseInt(10 + defaults.offset)
                },
                'out': {
                    'start': {
                        'top': parseInt(defaults.height - (defaults.height / 2))
                    },
                    'end': {
                        'top': parseInt(0 - (defaults.height * 2))
                    }
                }
            },
            'bottom': {
                'css_start': {
                    "top": 'auto',
                    "bottom": parseInt(0 - (defaults.height + 10)),
                    "left": mid - parseInt(defaults.width / 2)
                },
                'in': {
                    'bottom': parseInt(10 + defaults.offset)
                },
                'out': {
                    'start': {
                        'bottom': parseInt(defaults.height - (defaults.height / 2))
                    },
                    'end': {
                        'bottom': parseInt(0 - (defaults.height * 2))
                    }
                }
            },
            'right': {
                'css_start': {
                    "right": parseInt(0 - (defaults.width + 10)),
                    "right": parseInt(0 - (defaults.width * 2)),
                    "top": defaults.vertoffset
                },
                'in': {
                    'right': parseInt(10 + defaults.offset)
                },
                'out': {
                    'start': {
                        'right': parseFloat(defaults.width - (defaults.width * 0.9))
                    },
                    'end': {
                        'right': parseInt(0 - (defaults.width * 2))
                    }
                }
            },
            'left': {
                'css_start': {
                    "left": parseInt(0 - (defaults.width + 10))
                },
                'in': {
                    'left': parseInt(10 + defaults.offset)
                },
                'out': {
                    'start': {
                        'left': parseFloat(defaults.width - (defaults.width * 0.9))
                    },
                    'end': {
                        'left': parseInt(0 - (defaults.width * 2))
                    }
                }
            }
        };
        // Zoom animation
        defaults.animations.zoom = {
            'center': { // Not working well
                'css_start': {
                    "top": 10,
                    "left": mid - parseInt(defaults.width / 2),
                    "zoom": 0.01
                },
                'in': {
                    'zoom': 1
                },
                'out': {
                    'start': {
                        'zoom': 1.3
                    },
                    'end': {
                        'zoom': 0.01
                    }
                }
            },
            'bottom': { // Not working well
                'css_start': {
                    "top": 'auto',
                    "bottom": 10,
                    "left": mid - parseInt(defaults.width / 2),
                    "zoom": 0.01
                },
                'in': {
                    'zoom': 1
                },
                'out': {
                    'start': {
                        'zoom': 1.3
                    },
                    'end': {
                        'zoom': 0.01
                    }
                }
            },
            'right': {
                'css_start': {
                    'right': 10,
                    'zoom': 0.01
                },
                'in': {
                    'right': parseInt(10 + defaults.offset),
                    'zoom': 1
                },
                'out': {
                    'start': {
                        'zoom': 1.3
                    },
                    'end': {
                        'zoom': 0.01
                    }
                }
            },
            'left': {
                'css_start': {
                    'left': 10,
                    'zoom': 0.01
                },
                'in': {
                    'zoom': 1
                },
                'out': {
                    'start': {
                        'zoom': 1.3
                    },
                    'end': {
                        'zoom': 0.01
                    }
                }
            }
        };
        // Check if animation exists
        defaults.available_animations = Object.keys(defaults.animations)
        if (!defaults.available_animations.length) {
            throw new Error('No animations')
        }
        if (!available_positions.length) {
            throw new Error('No available positions')
        }
        if (available_positions.indexOf(defaults.position) === -1) {
            defaults.position = available_positions[0]
        }
        if (defaults.available_animations.indexOf(defaults.animation) === -1) {
            defaults.animation = defaults.available_animations[0]
        }
        // Check callback
        if (typeof defaults.callback !== 'function') {
            defaults.callback = null;
        }
        // Width & Height
        if (defaults.width > 0) {
            defaults.width = defaults.width;
        } else if (defaults.width === "all") {
            defaults.width = screen.width - 60;
        } else {
            defaults.width = 400;
        }
        if (defaults.height < 100 && defaults.height > 0) {
            height = defaults.height;
        }
        // Create notification itself
        var div = create_notification()
            // If clickable add close button
        if (defaults.clickable) {
            div.append(create_close_button())
        }
        // Remove div before appending, we don't want to duplicate
        var destroy = function() {
            $("#ui_notifIt").remove();
            clearInterval(window.notifit_timeout);
        }
        destroy();
        $("body").append(div);
        // Set z-index
        if (defaults.zindex) {
            $("#ui_notifIt").css("z-index", defaults.zindex);
        }
        // If multiline we have to set the padding instead line-height
        if (defaults.multiline) {
            $("#ui_notifIt").css("padding", 15);
        } else {
            $("#ui_notifIt").css("height", height);
            $("#ui_notifIt p").css("line-height", height + "px");
        }
        // Basic css
        $("#ui_notifIt").css({
            "width": defaults.width,
            "opacity": defaults.opacity,
            "background-color": defaults.bgcolor,
            "color": defaults.color
        });
        // Class 'success', 'error', 'warning', 'info'..
        $("#ui_notifIt").addClass(defaults.type);
        // Set entry animation   
        if (defaults.animations[defaults.animation][defaults.position].css_start) {
            $("#ui_notifIt").css(defaults.animations[defaults.animation][defaults.position].css_start);
        } else {
            $("#ui_notifIt").css(defaults.animations[defaults.available_animations[0]][defaults.position].css_start);
        }
        // Execute entry animation
        $("#ui_notifIt").animate(defaults.animations[defaults.animation][defaults.position].in);
        // Events
        if (!defaults.clickable) {
            $("#ui_notifIt").click(function(e) {
                e.stopPropagation();
                notifit_dismiss(defaults);
            });
        }
        $('body').on('click', '#ui_notifIt #notifIt_close', function() {
            notifit_dismiss(defaults);
        });
        if (defaults.autohide) {
            if (!isNaN(defaults.timeout)) {
                window.notifit_timeout = setTimeout(function() {
                    notifit_dismiss(defaults);
                }, defaults.timeout);
            }
        }
        return {
            'destroy': destroy
        }
    }

    function notifit_dismiss(config) {
        clearTimeout(window.notifit_timeout);
        if (config.animation != 'fade') {
            // Set animations
            if (config.animations && config.animations[config.animation] && config.animations[config.animation][config.position] && config.animations[config.animation][config.position].out && config.animations[config.animation][config.position].out.start && config.animations[config.animation][config.position].out.end) {
                animation1 = config.animations[config.animation][config.position].out.start
                animation2 = config.animations[config.animation][config.position].out.end
            } else if (config.animations[config.available_animations[0]] && config.animations[config.available_animations[0]][config.position] && config.animations[config.available_animations[0]][config.position].out && config.animations[config.available_animations[0]][config.position].out.start && config.animations[config.available_animations[0]][config.position].out.end) {
                animation1 = config.animations[config.available_animations[0]][config.position].out.start
                animation2 = config.animations[config.available_animations[0]][config.position].out.end
            } else {
                throw new Error('Invalid animation')
            }
            // Execute animations       
            $("#ui_notifIt").animate(animation1, 100, function() {
                $("#ui_notifIt").animate(animation2, 100, function() {
                    $("#ui_notifIt").remove();
                    if (config.callback) {
                        config.callback();
                    }
                });
            });
        } else {
            // jQuery's fade, why create my own?
            $("#ui_notifIt").fadeOut("slow", function() {
                $("#ui_notifIt").remove();
                if (config.callback) {
                    config.callback();
                }
            });
        }
    }
    return {
        notif: notif,
        notifit_dismiss: notifit_dismiss
    };
}));
