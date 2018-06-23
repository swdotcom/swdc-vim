" ============================================================================
" File:        software.vim
" Description: Insights into how you code for Vim
" Website:     https://software.com
" ============================================================================

let s:VERSION = '1.1.0'
let s:local_api_endpoint = 'http://localhost:5000'
let s:local_url_endpoint = 'http://localhost:3000'
let s:prod_api_endpoint = 'https://alpha.software.com'
let s:prod_url_endpoint = 'https://alpha.software.com'

"
" uncomment this and the 'echo' commands when releasing this plugin.
"....
set shortmess=a
set cmdheight=10

" Init {{{

    " Check Vim version:
    if v:version < 700
        echoerr "This plugin requires vim >= 7."
        finish
    endif

    " Avoid side-effects from cpoptions setting.
    let s:save_cpo = &cpo
    set cpo&vim
 
    " Use constants for boolean checks
    let s:true = 1
    let s:false = 0

    " Check if we've already loaded the plugin or not
    if exists("g:loaded_softwareco")
       finish
    endif
    let g:loaded_softwareco = s:true

    let s:home = expand("$HOME")
    " ...
    let s:api_endpoint = s:local_api_endpoint
    let s:softwareDataDir = s:home . "/.software"
    let s:softwareSessionFile = s:softwareDataDir . "/session.json"
    let s:currentJwt = ""
    let s:currentToken = ""
    let s:currentSessionDict = {}
    let s:curlOutputFile = s:softwareDataDir . "/vim.out"

    " api
    let s:pm_endpoint = 'http://localhost:19234/api/v1/data'

    " event management vars
    let s:kpm_count = 0
    let s:current_file_size = 0
    let s:last_time_check = localtime()
    let s:events = {
                \ 'source': {},
                \ 'type': 'Events',
                \ 'data': 0,
                \ 'start': 0,
                \ 'end': 0,
                \ 'project': {'name': '', 'directory': ''},
                \ 'pluginId': 10,
                \ 'version': '0.1.0'
                \ } 

    " flag to indicate if we should error non-communication with the plugin manager or not
    let g:reported_api_err = s:false

    function! s:Init()
        " initialization logic 
        call s:getSoftwareSessionFile()
        " call s:curl("GET", [s:api_endpoint . "/ping"])
    endfunction
    
    function! s:ResetData()
         " reset the data and, start, end, source, and project
         let s:events.source = {} 
         let s:events.start = localtime()
         let s:events.end = 0
         let s:events.project = {'name': '', 'directory': ''}
         let s:events.data = 0
         let s:last_time_check = localtime()
    endfunction

    " expand('%:t')      my.txt              name of file ('tail')
    " @%                 def/my.txt          relative directory/name
    " expand('%:p')      /abc/def/my.txt     full path
    " expand('%:p:h')    /abc/def            directory containing file ('head')
    " expand('%:p:h:t')  def                 get the head, then get the tail
    " expand('%:r')      def/my              name of file without the extension
    " expand('%:e')      txt                 get the file's extension

    function! s:GetCurrentFile()
        return expand('%:p')
    endfunction

    function! s:GetFileDirectory()
        return expand('%:p:h')
    endfunction

    function! s:GetDirectoryName()
        return expand('%:p:h:t')
    endfunction

    function! s:GetFileCharacterLen()
        execute "silent normal g\<c-g>"
        if exists("v:statusmsg")
          let s:splitmsg = split(v:statusmsg)
          if len(s:splitmsg) > 15
            return str2nr(s:splitmsg[15])
          endif
        endif
        return 0
    endfunction

    " incement the kpm count if the user is entering data
    function! s:IncrementKPM()
        if v:insertmode != 'i'
            return
        endif

        let s:kpm_count = s:kpm_count + 1

        call s:InitializeProject()

        let s:file = s:GetCurrentFile()
        call s:InitializeFileEvents(s:file)

        let s:events.source[s:file]['keys'] = s:events.source[s:file]['keys'] + 1
        let s:events.data = s:events.data + 1
        " echo 'Software.com: KPM incremented'

        if s:EnoughTimePassed()
          call s:SendData()
        endif

    endfunction

    function! s:InitializeFileEvents(file)
        " set the start seconds if it's zero
        if s:events.start == 0
           let s:events.start = localtime()
        endif

        if !has_key(s:events.source, a:file)
           " we don't have the file info data yet, create this structure
           let s:events.source[a:file] = {'keys': 0, 'paste': 0, 'open': 0, 'close': 0, 'delete': 0, 'length': 0}
        endif
    endfunction

    function! s:InitializeProject()
      let s:dir = s:GetFileDirectory()
      let s:dirName = s:GetDirectoryName()

      " update the events object
      if s:events.project.name == ''
          " initialize it
          let s:events.project.name = s:dirName
          let s:events.project.directory = s:dir
      endif
    endfunction

    function! s:Timer()
        call s:SendData()
        call feedkeys("f\e")
    endfunction

    " Send the payload to the plugin manager if it meets the timecheck and data availability check
    function! s:SendData()
        if s:EnoughTimePassed() == s:true
            if s:HasData() == s:true
                " It passes the time passed check and we have keystroke info to send
                " update end time to now
                let s:events.end = s:events.start

                " update data to a string
                let s:events.data = string(s:events.data)

                let s:jsonbody = "'{"
                let s:len = len(s:events)
                let s:counter = 0
                for key in keys(s:events)
                    if key == 'project'
                        let s:jsonbody = s:BuildJsonFromObj(s:jsonbody, s:events, key)
                    elseif key == 'source'
                        " go trhough the file names and build the json object
                        " per file name
                        for key in keys(s:events.source)
                            let s:jsonbody = s:jsonbody . '"source": {"' . key . '": {'
                            let s:file_event_info = s:events.source[key]
                            let s:maplen = len(s:file_event_info)
                            let s:source_counter = 0
                            for infoKey in keys(s:file_event_info)
                                let s:jsonbody = s:jsonbody . '"' . infoKey . '": ' . s:file_event_info[infoKey]
                                let s:source_counter = s:source_counter + 1
                                if s:source_counter < s:maplen
                                    let s:jsonbody = s:jsonbody . ", "
                                endif
                            endfor
                            let s:jsonbody = s:jsonbody . "}}"
                        endfor
                    else
                        let s:keyval = s:BuildInnerValue(s:events, key)
                        let s:jsonbody = s:jsonbody . '"' . key . '": ' . s:keyval
                    endif
                    let s:counter = s:counter + 1
                    if s:counter < s:len
                        let s:jsonbody = s:jsonbody . ", "
                    endif
                endfor
                let s:jsonbody = s:jsonbody . "}'"
                " ...
                call s:ResetData()

                let s:jsonResp = s:executeCurl("POST", "/data", s:jsonbody)

                " old way...
                " echo "Software.com: sending data"
                " execute "silent !curl -d " . s:jsonbody . " -H 'Content-Type: application/json' 
                    " \ --silent --output /dev/null -X POST " . s:api_endpoint

                let s:status = s:isOk(s:jsonResp)

                if s:status == s:false
                    " save the data offline
                endif
            endif 

        endif
    endfunction

    function! s:LaunchDashboard()
        let s:web_url = "https://alpha.software.com"

        let s:jwt = s:getItem("jwt")
        if !exists(s:jwt)
            " no jwt, launch the onboarding url
            " generate a random token
            let s:tokenVal = "abc123"
            let s:web_url = s:web_url . "/onboarding?token=" . s:tokenVal
        endif
        execute "silent !open " . s:web_url
    endfunction

    function! s:isOk(jsonresp)
        if !exists(a:jsonresp) || a:jsonresp["code"] != 200
            return s:false
        endif

        return s:true
    endfunction

    " executes an api request (i.e. s:executeCurl("POST", "", s:jsonbody)) 
    "
    "....
    " with response....
    " % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
    " Dload  Upload   Total   Spent    Left  Speed
    " 100   422  100    64  100   358  24436   133k --:--:-- --:--:-- --:--:--  174k
    " {"data":{"status":404},"message":"Resource not found","code":""}
    " OR {"data":"pong","message":"success","code":200}
    "
    " no response...
    " % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
    " Dload  Upload   Total   Spent    Left  Speed
    " 0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0curl: (7) Failed to connect to localhost port 5000: Connection refused
    "
    " not authorized...
    " % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
    " Dload  Upload   Total   Spent    Left  Speed
    " 100    12    0    12    0     0   4985      0 --:--:-- --:--:-- --:--:--  6000
    " Unauthorized
    "
    function! s:executeCurl(method, api, optionalPayload)

        let s:methodStr = "-X GET"
        if tolower(a:method) == "post"
            let s:methodStr = "-X POST"
        endif

        let s:headers = "-H 'Content-Type: application/json'"
        " look for the jwt token and add it to the headers if we have it
        let s:jwt = s:getItem("jwt")
        if exists(s:jwt)
            let s:headers = s:headers . " -H 'Authorization: " . s:jwt . "'"
        endif

        let s:payload = ""
        if exists(a:optionalPayload) && a:optionalPayload != ""
            let s:payload = "-d " . a:optionalPayload
        endif

        let s:endpoint = s:api_endpoint . "" . a:api
        let s:command = "curl " . s:payload . " " . s:headers . " " . s:methodStr . " " . s:endpoint

        " get the response
        let s:res = system(s:command)
        " ...
        " echo "RESPONSE: " . s:res
        let s:jsonResp = {}
        let s:pos = stridx(s:res, "{")
        let s:unauthPos = stridx(s:res, "Unauthorized")
        let s:badReqPos = stridx(s:res, ":404")
        if s:pos != -1
            let s:jsonResp = json_decode(strpart(s:res, s:pos, len(s:res) - 1))
        elseif s:unauthPos != -1
            " let s:jsonResp = strpart(s:res, s:unauthPos, len(s:res) - 1)
            let s:jsonResp = {'code':401}
        elseif s:badReqPos != -1
            let s:jsonResp = {'code':404}
        else
            let s:jsonResp = {'code':500}
        endif

        return s:jsonResp
    endfunction

    " ....
    function! s:BuildJsonFromObj(json, obj, key)
        let s:jsonbody = a:json
        let s:val = a:obj[a:key]
        let s:vallen = len(s:val)
        let s:valcounter = 0

        let s:jsonbody = s:jsonbody . '"' . a:key . '": {'
        for subkey in keys(s:val)
            " get the value. if it's a string type remove the single quote
            " and replace it with a double quote
            let s:subkeyval = s:BuildInnerValue(s:val, subkey)

            " set the key value pair 
            let s:jsonbody = s:jsonbody . '"' . subkey . '": ' . s:subkeyval
            let s:valcounter = s:valcounter + 1
            if s:valcounter < s:vallen
                let s:jsonbody = s:jsonbody . ", "
            endif
        endfor
        let s:jsonbody = s:jsonbody . "}" 
        " return the new jsonbody string 
        return s:jsonbody
    endfunction

    function! s:ToJson(input)
        let json = ''
        if type(a:input) == type({})
            let parts = deepcopy(a:input)
            call map(parts, '"\"" . escape(v:key, "\"") . "\":" . s:ToJson(v:val)')
            let json .= "{" . join(values(parts), ",") . "}"
        elseif type(a:input) == type([])
            let parts = map(deepcopy(a:input), 's:ToJson(v:val)')
            let json .= "[" . join(parts, ",") . "]"
        else
            let json .= '"'.escape(a:input, '"').'"'
        endif
        return json
    endfunction

    function! s:BuildInnerValue(valobj, valobjkey)
        " get the value. if it's a string type remove the single quote
        " and replace it with a double quote
        let s:subkeyval = a:valobj[a:valobjkey]
        if type(a:valobj[a:valobjkey]) == type("")
            let s:subkeyval = substitute(a:valobj[a:valobjkey], '\\n', '', 'g')
            let s:subkeyval = '"' . s:subkeyval . '"'
        endif
        return s:subkeyval
    endfunction

    function! s:HasData()
        " go through the file events to see if any of the other metrics have data
        for key in keys(s:events.source)
            let s:file_event_info = s:events.source[key]
            for infoKey in keys(s:file_event_info)
                if infoKey == "length"
                    continue
                endif
                let s:infoVal = s:file_event_info[infoKey]
                if s:infoVal > 0
                    return s:true
                endif
            endfor
        endfor

        return s:false
    endfunction

    function! s:EnoughTimePassed()
        let s:prev = s:last_time_check 
        let s:now = localtime()
        if s:prev > 0 && s:now - s:prev > 60 
            return s:true
        endif
        return s:false
    endfunction

    function! s:getSoftwareSessionFile()
       " make sure the dir exists, if not, create it
       if !isdirectory(s:softwareDataDir)
           call mkdir(s:softwareDataDir, "p")
       endif
    endfunction

    function! s:getSoftwareSessionAsJson()
        call s:getSoftwareSessionFile() 
        let s:content = ""
        if filereadable(s:softwareSessionFile)
            " get the contents in json format
            let lines = readfile(s:softwareSessionFile)
            " there should only be one line for the session.json file
            for line in lines
                let s:content = s:content . line
            endfor
            " get the value for the incoming key
            let s:currentSessionDict = eval(s:content)
        else
            echo "No lines to read"
            let s:currentSessionDict = {}
        endif
    endfunction

    function! s:getItem(key)
        call s:getSoftwareSessionAsJson()
        return s:currentSessionDict[a:key]
    endfunction

    function! s:setItem(key, val)
        call s:getSoftwareSessionAsJson()
        let s:currentSessionDict[a:key] = a:val
        echo "updated key/value: " . a:key . "/" . a:val
        " let s:jsonbody = s:ToJson(s:newItem)
        " call writefile([s:jsonbody], s:softwareSessionFile)
    endfunction

    function! s:CheckUserAuthentication()
        echo "Checking use authentication status"
        call s:getSoftwareSessionAsJson()
        let s:jwtVal = get(s:currentSessionDict, "jwt)
        if s:jwtVal == 0
            " no jwt value, show the sign in message 
            set cmdheight=5
            try
                execute "silent open \"http://alpha.software.com\""
            catch
                echoerr "Unable to open url: " . v:exception
            endtry
        else
            " has a jwt value
        endif
    endfunction

    " handle curosor activity, but if it's a recognized kpm, call the increment kpm function 
    function! s:HandleCursorActivity()
        if v:insertmode != 'i' 
            return
        endif

        let s:file = s:GetCurrentFile()
        if !empty(s:file) && s:file !~ "-MiniBufExplorer-" && s:file !~ "--NO NAME--" && s:file !~ "^term:" 
            " increment the kpm data
            call s:IncrementKPM() 
        endif 
    endfunction

    " handle file open
    function! s:HandleNewFileActivity()
      call s:InitializeProject()

      let s:file = s:GetCurrentFile()
      call s:InitializeFileEvents(s:file)

      let s:events.source[s:file]['open'] = s:events.source[s:file]['open'] + 1 
      " echo "Software.com: File open incremented"
    endfunction

    function! s:HandleInsertEnterActivity()
      " handle when entering insert mode
      let s:kpm_count = s:GetFileCharacterLen()
    endfunction

    function! s:HandleFileReadPostActivity()
      let s:kpm_count = s:GetFileCharacterLen()
    endfunction

    function! s:HandleInsertLeaveActivity()
      " handle when leaving insert mode
      call s:HandleLeaveInsertOrBufLeave(s:true)
    endfunction

    function! s:HandleCursorHoldInInsertActivity()
      " handle no activity when in insert mode
      call s:HandleLeaveInsertOrBufLeave(s:false)
    endfunction

    function! s:HandleLeaveInsertOrBufLeave(sendDataOverride)
      let s:current_file_size = s:GetFileCharacterLen()
      let s:diff = 0
      if s:current_file_size > 0
        let s:diff = s:current_file_size - s:kpm_count
      endif

      " make sure we don't count the entire file size as copy and
      " paste if all they did was start an insert but then saved it
      " without making any key stroke
      if s:diff > 0 && s:kpm_count == 0
        let s:diff = 0
      endif

      let s:file = s:GetCurrentFile()
      call s:InitializeFileEvents(s:file)
      if s:diff > 1
        " increment the paste count
        let s:events.source[s:file]['paste'] = s:events.source[s:file]['paste'] + s:diff
        " echo 'Software.com: Copy+Paste incremented'
      elseif s:diff < 0
        let s:events.source[s:file]['delete'] = s:events.source[s:file]['delete'] + abs(s:diff)
        " echo 'Software.com: Delete incremented'
      elseif s:diff == 1
        let s:events.source[s:file]['keys'] = s:events.source[s:file]['keys'] + 1
        let s:events.data = s:events.data + 1
        " echo 'Software.com: KPM incremented'
      endif
      let s:kpm_count = s:current_file_size

      " update the length for this file
      let s:events.source[s:file]['length'] = s:current_file_size

      if a:sendDataOverride == s:true || s:EnoughTimePassed()
        call s:SendData()
      endif
    endfunction

    function! s:HandleCursorMovedActivity()
      if &modified == 1
        " it's a delete since we're not in insert mo
        call s:InitializeProject()
        let s:file = s:GetCurrentFile()
        call s:InitializeFileEvents(s:file)

        let s:file_len = s:GetFileCharacterLen()
        let s:file_diff = s:file_len - s:events.source[s:file].length
        if s:file_diff < 0
          let s:events.source[s:file]['delete'] = s:events.source[s:file]['delete'] + 1
          " echo 'Software.com: Delete incremented'
          let s:events.source[s:file]['length'] = s:file_len
        endif
      endif
    endfunction

" }}}


" Autocommand Events {{{

    " listen for events then call the specified function based on the event
    augroup SoftwareCo
        autocmd CursorMovedI * call s:HandleCursorActivity()
        autocmd CursorHold * call s:Timer()
        autocmd CursorHoldI * call s:HandleCursorHoldInInsertActivity()
        autocmd BufNewFile,BufReadPost * call s:HandleNewFileActivity()
        autocmd InsertLeave,BufWritePost * call s:HandleInsertLeaveActivity()
        autocmd InsertEnter * call s:HandleInsertEnterActivity()
        autocmd CursorMoved * call s:HandleCursorMovedActivity()
    augroup END

" }}}

call s:Init()

let &cpo = s:save_cpo
finish

" vim:set tw=0:
