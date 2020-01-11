// Future versions of Hyper may add additional config options,
// which will not automatically be merged into this file.
// See https://hyper.is#cfg for all currently supported options.

module.exports = {
    config: {
        // Choose either "stable" for receiving highly polished,
        // or "canary" for less polished but more frequent updates
        updateChannel: 'stable',

        // default font size in pixels for all tabs
        fontSize: 13,

        // font family with optional fallbacks
        fontFamily: 'Menlo, "DejaVu Sans Mono", Consolas, "Lucida Console", monospace',

        // terminal cursor background color and opacity (hex, rgb, hsl, hsv, hwb or cmyk)
        cursorColor: 'rgba(248,28,229,0.8)',

        // `BEAM` for |, `UNDERLINE` for _, `BLOCK` for █
        cursorShape: 'BEAM',

        // set to true for blinking cursor
        cursorBlink: false,

        // The background color/opacity of the text selection in terminal
        selectionColor: 'rgba(98, 114, 164, 0.3)',

        // custom css to embed in the main window
        css: '',

        // custom css to embed in the terminal window
        termCSS: ``,

        // custom padding (css format, i.e.: `top right bottom left`)
        padding: '12px 14px',

        // for setting shell arguments (i.e. for using interactive shellArgs: ['-i'])
        // by default ['--login'] will be used
        shellArgs: ['--login'],

        // for environment variables
        env: {},

        // set to false for no bell
        bell: 'false',

        // if true, selected text will automatically be copied to the clipboard
        copyOnSelect: false,

        // for advanced config flags please refer to https://hyper.is/#cfg

        // ========================================================================= //
        // ======================== begin of plugins config ======================== //
        // ========================================================================= //

        // for https://www.npmjs.com/package/hyper-confirm
        confirmQuit: true,

        // for https://www.npmjs.com/package/hyper-pane
        paneNavigation: {
            debug: false,
            hotkeys: {
                navigation: {
                    up: 'ctrl+alt+up',
                    down: 'ctrl+alt+down',
                    left: 'ctrl+alt+left',
                    right: 'ctrl+alt+right'
                },
                jump_prefix: 'ctrl', // completed with 1-9 digits
                permutation_modifier: 'shift', // Added to jump and navigation hotkeys for pane permutation
                maximize: 'meta+enter'
            },
            showIndicators: true, // Show pane number
            indicatorPrefix: '^', // Will be completed with pane number
            indicatorStyle: { // Added to indicator <div>
                position: 'absolute',
                top: 0,
                left: 0,
                fontSize: '10px',
                color: 'lightBlue'
            }
        }

        // ========================================================================= //
        // ========================= end of plugins config ========================= //
        // ========================================================================= //
    },

    // a list of plugins to fetch and install from npm
    plugins: [
        'hyper-dark-scrollbar',
        'hyper-pane',
        "hyper-search",
        "hyper-dracula"
    ],

    // in development, you can create a directory under
    // `~/.hyper_plugins/local/` and include it here
    // to load it and avoid it being `npm install`ed
    localPlugins: [],

    keymaps: {
        // Example
        // 'window:devtools': 'cmd+alt+o',
    }
};