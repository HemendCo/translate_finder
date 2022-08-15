# translate_finder

simple CLI application used to extract translations from source code.

```log
--extensions
    supported file extensions
    (defaults to "vue", "js", "ts")


--include                                                       directories to look for translations
    (defaults to "components", "pages")


-d,--directory                                                      (defaults to "Current Working directory")


-l,
--locale_directory
    default address to locales directory 


--regex
    regex pattern to find translations default bad-words are one of `) or (`  


--start_offset
    select text after matching with given regex pattern with this starting offset


--end_offset
    select text after matching with given regex pattern with this ending offset


-o,--output
    output file path (actually a temp file)
    (defaults to "translations.json")


-w,--[no-]watch
    watch for changes in the working directory (this flag will cause the program to run in a loop with force mode on)


-v,--[no-]verbose 



-c,--config                                                                                          config scope
                                                                            [local, global, none (default)]

-s,--[no-]save                                                                                       save the current config to local or global config


-h, --help                                                                                   show this help message
```

use `translate_finder -h` for more information.

use `translate_finder --config local --save` to save current config into a `json` file

```JavaScript
{
    // directories that will be searched for translations
    "selectedDirectories": [
        "components",
        "pages"
    ],
    // file extensions that will be searched for translations
    "supportedExtensions": [
        "vue",
        "js",
        "ts"
    ],
    // base directory to look for [selectedDirectories]
    "workingDirectory": "<SOME-DIR>",
    // locales directory containing json file for different languages
    "localeDirectory": "<SOME-DIR>/locales",
    // temp output file for last scan results
    "tempOutputFile": "translations.json",
    // show more information about the scan process
    "isVerbose": true,
    // cli will not exit after first full scan process instead it will stay in a loop and watch for changes in the working directory and files
    "watch": true,
    // regex pattern to find translations in this case `...$t('some-key')...` will be extracted as `$t('some-key')`
    "regex": "(\\$t\\(([^}{<>\\n])*\\'\\))",  
    // select text after matching with given regex pattern with this starting offset by default is 4 because it starts with `$t('`
    "startingOffset": 4,
    // select text after matching with given regex pattern with this ending offset by default is -2 because it ends with `')`
    "endingOffset": -2
}
```

to load the config located in the directory use `translate_finder --config(or -c) local` without any other arguments.
