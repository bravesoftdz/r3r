{$IFNDEF LIBCURL_MONOLITHIC}
unit CurlCore;

interface

uses
  CurlSList;

{$include "curllib.inc"}
{$ENDIF}

{
  Automatically converted by H2Pas 1.0.0 from curl.h
  The following command line parameters were used:
    -D
    -l
    curl
    -o
    curlcore.pas
    -S
    -u
    CurlCore
    curl.h
}

  Type
    dword     = cardinal;
    Plongint  = ^longint;
    PPChar    = ^PChar;

  type
    PCURL  = ^CURL;
    CURL = pointer;

type
    curl_progress_callback = function (clientp:pointer; dltotal:double; dlnow:double; ultotal:double; ulnow:double):longint;

  const
    CURL_MAX_WRITE_SIZE = 16384;

  const
    CURL_MAX_HTTP_HEADER = 100*1024;

  const
    CURL_WRITEFUNC_PAUSE = $10000001;

  type

    curl_write_callback = function (buffer:Pchar; size:integer; nitems:integer; outstream:pointer):integer;

    curlfiletype = (CURLFILETYPE_FILE,CURLFILETYPE_DIRECTORY,
      CURLFILETYPE_SYMLINK,CURLFILETYPE_DEVICE_BLOCK,
      CURLFILETYPE_DEVICE_CHAR,CURLFILETYPE_NAMEDPIPE,
      CURLFILETYPE_SOCKET,CURLFILETYPE_DOOR,
      CURLFILETYPE_UNKNOWN);

  const
    CURLFINFOFLAG_KNOWN_FILENAME = 1 shl 0;
    CURLFINFOFLAG_KNOWN_FILETYPE = 1 shl 1;
    CURLFINFOFLAG_KNOWN_TIME = 1 shl 2;
    CURLFINFOFLAG_KNOWN_PERM = 1 shl 3;
    CURLFINFOFLAG_KNOWN_UID = 1 shl 4;
    CURLFINFOFLAG_KNOWN_GID = 1 shl 5;
    CURLFINFOFLAG_KNOWN_SIZE = 1 shl 6;
    CURLFINFOFLAG_KNOWN_HLINKCOUNT = 1 shl 7;

  type
    curl_off_t = integer;
    curl_fileinfo = record
        filename : PChar;
        filetype : curlfiletype;
        time : integer;
        perm : dword;
        uid : longint;
        gid : longint;
        size : curl_off_t;
        hardlinks : longint;
        strings : record
            time : PChar;
            perm : PChar;
            user : PChar;
            group : PChar;
            target : PChar;
          end;
        flags : dword;
        b_data : PChar;
        b_size : integer;
        b_used : integer;
      end;

  const
    CURL_CHUNK_BGN_FUNC_OK = 0;

    CURL_CHUNK_BGN_FUNC_FAIL = 1;

    CURL_CHUNK_BGN_FUNC_SKIP = 2;

  type

    curl_chunk_bgn_callback = function (transfer_info:pointer; ptr:pointer; remains:longint):longint;

  const
    CURL_CHUNK_END_FUNC_OK = 0;

    CURL_CHUNK_END_FUNC_FAIL = 1;

  type

    curl_chunk_end_callback = function (ptr:pointer):longint;

  const
    CURL_FNMATCHFUNC_MATCH = 0;

    CURL_FNMATCHFUNC_NOMATCH = 1;

    CURL_FNMATCHFUNC_FAIL = 2;

  type

    curl_fnmatch_callback = function (ptr:pointer; pattern:Pchar; _string:Pchar):longint;

  const
    CURL_SEEKFUNC_OK = 0;

    CURL_SEEKFUNC_FAIL = 1;

    CURL_SEEKFUNC_CANTSEEK = 2;

  type

    curl_seek_callback = function (instream:pointer; offset:curl_off_t; origin:longint):longint;

  const
    CURL_READFUNC_ABORT = $10000000;

    CURL_READFUNC_PAUSE = $10000001;

  type

    curl_read_callback = function (buffer:Pchar; size:integer; nitems:integer; instream:pointer):integer;

    curlsocktype = (CURLSOCKTYPE_IPCXN,CURLSOCKTYPE_LAST
      );

  const
    CURL_SOCKET_BAD = -1;

    CURL_SOCKOPT_OK = 0;

    CURL_SOCKOPT_ERROR = 1;
    CURL_SOCKOPT_ALREADY_CONNECTED = 2;

  type
    curl_socket_t = pointer;

    curl_sockopt_callback = function (clientp:pointer; curlfd:curl_socket_t; purpose:curlsocktype):longint;

    Pcurl_sockaddr  = ^curl_sockaddr;
    curl_sockaddr = record
        family : longint;
        socktype : longint;
        protocol : longint;
        addrlen : dword;
        addr : record
        end;
      end;

    curl_opensocket_callback = function (clientp:pointer; purpose:curlsocktype; address:Pcurl_sockaddr):curl_socket_t;

    curl_closesocket_callback = function (clientp:pointer; item:curl_socket_t):longint;

    curlioerr = (CURLIOE_OK,CURLIOE_UNKNOWNCMD,CURLIOE_FAILRESTART,
      CURLIOE_LAST);

    curliocmd = (CURLIOCMD_NOP,CURLIOCMD_RESTARTREAD,CURLIOCMD_LAST
      );

    curl_ioctl_callback = function (handle:PCURL; cmd:longint; clientp:pointer):curlioerr;

    curl_malloc_callback = function (size:integer):pointer;

    curl_free_callback = procedure (ptr:pointer);

    curl_realloc_callback = function (ptr:pointer; size:integer):pointer;

    curl_strdup_callback = function (str:Pchar):Pchar;

    curl_calloc_callback = function (nmemb:integer; size:integer):pointer;

    curl_infotype = (CURLINFO_TEXT,CURLINFO_HEADER_IN,
      CURLINFO_HEADER_OUT,CURLINFO_DATA_IN,
      CURLINFO_DATA_OUT,CURLINFO_SSL_DATA_IN,
      CURLINFO_SSL_DATA_OUT,CURLINFO_END);

    curl_debug_callback = function (handle:PCURL; _type:curl_infotype; data:Pchar; size:integer; userptr:pointer):longint;

    CURLcode = (CURLE_OK,CURLE_UNSUPPORTED_PROTOCOL,
      CURLE_FAILED_INIT,CURLE_URL_MALFORMAT,
      CURLE_NOT_BUILT_IN,CURLE_COULDNT_RESOLVE_PROXY,
      CURLE_COULDNT_RESOLVE_HOST,CURLE_COULDNT_CONNECT,
      CURLE_FTP_WEIRD_SERVER_REPLY,CURLE_REMOTE_ACCESS_DENIED,
      CURLE_FTP_ACCEPT_FAILED,CURLE_FTP_WEIRD_PASS_REPLY,
      CURLE_FTP_ACCEPT_TIMEOUT,CURLE_FTP_WEIRD_PASV_REPLY,
      CURLE_FTP_WEIRD_227_FORMAT,CURLE_FTP_CANT_GET_HOST,
      CURLE_OBSOLETE16,CURLE_FTP_COULDNT_SET_TYPE,
      CURLE_PARTIAL_FILE,CURLE_FTP_COULDNT_RETR_FILE,
      CURLE_OBSOLETE20,CURLE_QUOTE_ERROR,CURLE_HTTP_RETURNED_ERROR,
      CURLE_WRITE_ERROR,CURLE_OBSOLETE24,CURLE_UPLOAD_FAILED,
      CURLE_READ_ERROR,CURLE_OUT_OF_MEMORY,
      CURLE_OPERATION_TIMEDOUT,CURLE_OBSOLETE29,
      CURLE_FTP_PORT_FAILED,CURLE_FTP_COULDNT_USE_REST,
      CURLE_OBSOLETE32,CURLE_RANGE_ERROR,CURLE_HTTP_POST_ERROR,
      CURLE_SSL_CONNECT_ERROR,CURLE_BAD_DOWNLOAD_RESUME,
      CURLE_FILE_COULDNT_READ_FILE,CURLE_LDAP_CANNOT_BIND,
      CURLE_LDAP_SEARCH_FAILED,CURLE_OBSOLETE40,
      CURLE_FUNCTION_NOT_FOUND,CURLE_ABORTED_BY_CALLBACK,
      CURLE_BAD_FUNCTION_ARGUMENT,CURLE_OBSOLETE44,
      CURLE_INTERFACE_FAILED,CURLE_OBSOLETE46,
      CURLE_TOO_MANY_REDIRECTS,CURLE_UNKNOWN_OPTION,
      CURLE_TELNET_OPTION_SYNTAX,CURLE_OBSOLETE50,
      CURLE_PEER_FAILED_VERIFICATION,CURLE_GOT_NOTHING,
      CURLE_SSL_ENGINE_NOTFOUND,CURLE_SSL_ENGINE_SETFAILED,
      CURLE_SEND_ERROR,CURLE_RECV_ERROR,CURLE_OBSOLETE57,
      CURLE_SSL_CERTPROBLEM,CURLE_SSL_CIPHER,
      CURLE_SSL_CACERT,CURLE_BAD_CONTENT_ENCODING,
      CURLE_LDAP_INVALID_URL,CURLE_FILESIZE_EXCEEDED,
      CURLE_USE_SSL_FAILED,CURLE_SEND_FAIL_REWIND,
      CURLE_SSL_ENGINE_INITFAILED,CURLE_LOGIN_DENIED,
      CURLE_TFTP_NOTFOUND,CURLE_TFTP_PERM,CURLE_REMOTE_DISK_FULL,
      CURLE_TFTP_ILLEGAL,CURLE_TFTP_UNKNOWNID,
      CURLE_REMOTE_FILE_EXISTS,CURLE_TFTP_NOSUCHUSER,
      CURLE_CONV_FAILED,CURLE_CONV_REQD,CURLE_SSL_CACERT_BADFILE,
      CURLE_REMOTE_FILE_NOT_FOUND,CURLE_SSH,
      CURLE_SSL_SHUTDOWN_FAILED,CURLE_AGAIN,
      CURLE_SSL_CRL_BADFILE,CURLE_SSL_ISSUER_ERROR,
      CURLE_FTP_PRET_FAILED,CURLE_RTSP_CSEQ_ERROR,
      CURLE_RTSP_SESSION_ERROR,CURLE_FTP_BAD_FILE_LIST,
      CURLE_CHUNK_FAILED,CURL_LAST);

  type

    curl_ssl_ctx_callback = function (curl:PCURL; ssl_ctx:pointer; userptr:pointer):CURLcode;

    curl_proxytype = (CURLPROXY_HTTP,CURLPROXY_HTTP_1_0,
      CURLPROXY_SOCKS2, CURLPROXY_SOCKS3, { added so GPC won't throw a fit; don't use }
      CURLPROXY_SOCKS4,CURLPROXY_SOCKS5,
      CURLPROXY_SOCKS4A,CURLPROXY_SOCKS5_HOSTNAME
      );

  const
    CURLAUTH_NONE = 0;

    CURLAUTH_BASIC = 1 shl 0;

    CURLAUTH_DIGEST = 1 shl 1;

    CURLAUTH_GSSNEGOTIATE = 1 shl 2;

    CURLAUTH_NTLM = 1 shl 3;

    CURLAUTH_DIGEST_IE = 1 shl 4;

    CURLAUTH_NTLM_WB = 1 shl 5;

    CURLAUTH_ONLY = 1 shl 31;

    CURLAUTH_ANY =  not (CURLAUTH_DIGEST_IE);
    CURLAUTH_ANYSAFE =  not (CURLAUTH_BASIC or CURLAUTH_DIGEST_IE);

    CURLSSH_AUTH_ANY =  not (0);

    CURLSSH_AUTH_NONE = 0;

    CURLSSH_AUTH_PUBLICKEY = 1 shl 0;

    CURLSSH_AUTH_PASSWORD = 1 shl 1;

    CURLSSH_AUTH_HOST = 1 shl 2;

    CURLSSH_AUTH_KEYBOARD = 1 shl 3;
    CURLSSH_AUTH_DEFAULT = CURLSSH_AUTH_ANY;

    CURLGSSAPI_DELEGATION_NONE = 0;

    CURLGSSAPI_DELEGATION_POLICY_FLAG = 1 shl 0;

    CURLGSSAPI_DELEGATION_FLAG = 1 shl 1;
    CURL_ERROR_SIZE = 256;

  type
    Pcurl_khkey  = ^curl_khkey;
    curl_khkey = record
        key : PChar;
        len : integer;
        keytype : (CURLKHTYPE_UNKNOWN,CURLKHTYPE_RSA1,
          CURLKHTYPE_RSA,CURLKHTYPE_DSS);
      end;

    curl_khstat = (CURLKHSTAT_FINE_ADD_TO_FILE,CURLKHSTAT_FINE,
      CURLKHSTAT_REJECT,CURLKHSTAT_DEFER,CURLKHSTAT_LAST
      );

    curl_khmatch = (CURLKHMATCH_OK,CURLKHMATCH_MISMATCH,CURLKHMATCH_MISSING,
      CURLKHMATCH_LAST);

    curl_sshkeycallback = function (easy:PCURL; knownkey:Pcurl_khkey; foundkey:Pcurl_khkey; _para4:curl_khmatch; clientp:pointer):longint;

    curl_usessl = (CURLUSESSL_NONE,CURLUSESSL_TRY,CURLUSESSL_CONTROL,
      CURLUSESSL_ALL,CURLUSESSL_LAST);
  type
    curl_ftpauth = (CURLFTPAUTH_DEFAULT,CURLFTPAUTH_SSL,CURLFTPAUTH_TLS,
      CURLFTPAUTH_LAST);

    curl_ftpcreatedir = (CURLFTP_CREATE_DIR_NONE,CURLFTP_CREATE_DIR,
      CURLFTP_CREATE_DIR_RETRY,CURLFTP_CREATE_DIR_LAST
      );

    curl_ftpmethod = (CURLFTPMETHOD_DEFAULT,CURLFTPMETHOD_MULTICWD,
      CURLFTPMETHOD_NOCWD,CURLFTPMETHOD_SINGLECWD,
      CURLFTPMETHOD_LAST);

  const
    CURLPROTO_HTTP = 1 shl 0;
    CURLPROTO_HTTPS = 1 shl 1;
    CURLPROTO_FTP = 1 shl 2;
    CURLPROTO_FTPS = 1 shl 3;
    CURLPROTO_SCP = 1 shl 4;
    CURLPROTO_SFTP = 1 shl 5;
    CURLPROTO_TELNET = 1 shl 6;
    CURLPROTO_LDAP = 1 shl 7;
    CURLPROTO_LDAPS = 1 shl 8;
    CURLPROTO_DICT = 1 shl 9;
    CURLPROTO_FILE = 1 shl 10;
    CURLPROTO_TFTP = 1 shl 11;
    CURLPROTO_IMAP = 1 shl 12;
    CURLPROTO_IMAPS = 1 shl 13;
    CURLPROTO_POP3 = 1 shl 14;
    CURLPROTO_POP3S = 1 shl 15;
    CURLPROTO_SMTP = 1 shl 16;
    CURLPROTO_SMTPS = 1 shl 17;
    CURLPROTO_RTSP = 1 shl 18;
    CURLPROTO_RTMP = 1 shl 19;
    CURLPROTO_RTMPT = 1 shl 20;
    CURLPROTO_RTMPE = 1 shl 21;
    CURLPROTO_RTMPTE = 1 shl 22;
    CURLPROTO_RTMPS = 1 shl 23;
    CURLPROTO_RTMPTS = 1 shl 24;
    CURLPROTO_GOPHER = 1 shl 25;

    CURLPROTO_ALL =  not (0);

    CURLOPTTYPE_LONG = 0;
    CURLOPTTYPE_OBJECTPOINT = 10000;
    CURLOPTTYPE_FUNCTIONPOINT = 20000;
    CURLOPTTYPE_OFF_T = 30000;

  const
    LONG = 0;
    OBJECTPOINT = 10000;
    FUNCTIONPOINT = 20000;
    OFF_T = 30000;

    CURLOPT_WRITEDATA =  OBJECTPOINT + 1;

    CURLOPT_URL =  OBJECTPOINT + 2;

    CURLOPT_PORT =  OBJECTPOINT + 3;

    CURLOPT_PROXY =  OBJECTPOINT + 4;

    CURLOPT_USERPWD =  OBJECTPOINT + 5;

    CURLOPT_PROXYUSERPWD =  OBJECTPOINT + 6;

    CURLOPT_RANGE =  OBJECTPOINT + 7;


    CURLOPT_INFILE =  OBJECTPOINT + 9;

    CURLOPT_ERRORBUFFER =  OBJECTPOINT + 10;

    CURLOPT_WRITEFUNCTION =  FUNCTIONPOINT + 11;

    CURLOPT_READFUNCTION =  FUNCTIONPOINT + 12;

    CURLOPT_TIMEOUT =  LONG + 13;

    CURLOPT_INFILESIZE =  LONG + 14;

    CURLOPT_POSTFIELDS =  OBJECTPOINT + 15;

    CURLOPT_REFERER =  OBJECTPOINT + 16;

    CURLOPT_FTPPORT =  OBJECTPOINT + 17;

    CURLOPT_USERAGENT =  OBJECTPOINT + 18;


    CURLOPT_LOW_SPEED_LIMIT =  LONG + 19;

    CURLOPT_LOW_SPEED_TIME =  LONG + 20;

    CURLOPT_RESUME_FROM =  LONG + 21;

    CURLOPT_COOKIE =  OBJECTPOINT + 22;

    CURLOPT_HTTPHEADER =  OBJECTPOINT + 23;

    CURLOPT_HTTPPOST =  OBJECTPOINT + 24;

    CURLOPT_SSLCERT =  OBJECTPOINT + 25;

    CURLOPT_KEYPASSWD =  OBJECTPOINT + 26;

    CURLOPT_CRLF =  LONG + 27;

    CURLOPT_QUOTE =  OBJECTPOINT + 28;

    CURLOPT_WRITEHEADER =  OBJECTPOINT + 29;

    CURLOPT_COOKIEFILE =  OBJECTPOINT + 31;

    CURLOPT_SSLVERSION =  LONG + 32;

    CURLOPT_TIMECONDITION =  LONG + 33;

    CURLOPT_TIMEVALUE =  LONG + 34;


    CURLOPT_CUSTOMREQUEST =  OBJECTPOINT + 36;

    CURLOPT_STDERR =  OBJECTPOINT + 37;


    CURLOPT_POSTQUOTE =  OBJECTPOINT + 39;

  CURLOPT_WRITEINFO =  OBJECTPOINT + 40;
  CURLOPT_VERBOSE =  LONG + 41;        CURLOPT_HEADER =  LONG + 42;         CURLOPT_NOPROGRESS =  LONG + 43;     CURLOPT_NOBODY =  LONG + 44;         CURLOPT_FAILONERROR =  LONG + 45;    CURLOPT_UPLOAD =  LONG + 46;         CURLOPT_POST =  LONG + 47;           CURLOPT_DIRLISTONLY =  LONG + 48;
  CURLOPT_APPEND =  LONG + 50;
    CURLOPT_NETRC =  LONG + 51;

  CURLOPT_FOLLOWLOCATION =  LONG + 52;
  CURLOPT_TRANSFERTEXT =  LONG + 53;   CURLOPT_PUT =  LONG + 54;

    CURLOPT_PROGRESSFUNCTION =  FUNCTIONPOINT + 56;

    CURLOPT_PROGRESSDATA =  OBJECTPOINT + 57;

    CURLOPT_AUTOREFERER =  LONG + 58;

    CURLOPT_PROXYPORT =  LONG + 59;

    CURLOPT_POSTFIELDSIZE =  LONG + 60;

    CURLOPT_HTTPPROXYTUNNEL =  LONG + 61;

    CURLOPT_INTERFACE =  OBJECTPOINT + 62;

    CURLOPT_KRBLEVEL =  OBJECTPOINT + 63;

    CURLOPT_SSL_VERIFYPEER =  OBJECTPOINT + 64;

    CURLOPT_CAINFO =  OBJECTPOINT + 65;


    CURLOPT_MAXREDIRS =  LONG + 68;

    CURLOPT_FILETIME =  LONG + 69;

    CURLOPT_TELNETOPTIONS =  OBJECTPOINT + 70;

    CURLOPT_MAXCONNECTS =  LONG + 71;

  CURLOPT_CLOSEPOLICY =  LONG + 72;

    CURLOPT_FRESH_CONNECT =  LONG + 74;

    CURLOPT_FORBID_REUSE =  LONG + 75;

    CURLOPT_RANDOM_FILE =  OBJECTPOINT + 76;

    CURLOPT_EGDSOCKET =  OBJECTPOINT + 77;

    CURLOPT_CONNECTTIMEOUT =  LONG + 78;

    CURLOPT_HEADERFUNCTION =  FUNCTIONPOINT + 79;

    CURLOPT_HTTPGET =  LONG + 80;

    CURLOPT_SSL_VERIFYHOST =  LONG + 81;

    CURLOPT_COOKIEJAR =  LONG + 82;

    CURLOPT_SSL_CIPHER_LIST =  LONG + 83;

    CURLOPT_HTTP_VERSION =  LONG + 84;

    CURLOPT_FTP_USE_EPSV =  LONG + 85;

    CURLOPT_SSLCERTTYPE =  OBJECTPOINT + 86;

    CURLOPT_SSLKEY =  OBJECTPOINT + 87;

    CURLOPT_SSLKEYTYPE =  OBJECTPOINT + 88;

    CURLOPT_SSLENGINE =  OBJECTPOINT + 89;

    CURLOPT_SSLENGINE_DEFAULT =  LONG + 90;

    CURLOPT_DNS_CACHE_TIMEOUT =  LONG + 92;

    CURLOPT_PREQUOTE =  OBJECTPOINT + 93;

    CURLOPT_DEBUGFUNCTION =  FUNCTIONPOINT + 94;

    CURLOPT_DEBUGDATA =  LONG + 95;

    CURLOPT_COOKIESESSION =  LONG + 96;

    CURLOPT_CAPATH =  OBJECTPOINT + 97;

    CURLOPT_BUFFERSIZE =  LONG + 98;

    CURLOPT_NOSIGNAL =  LONG + 99;

    CURLOPT_SHARE =  LONG + 100;

    CURLOPT_PROXYTYPE =  LONG + 101;

    CURLOPT_ACCEPT_ENCODING =  OBJECTPOINT + 102;

    CURLOPT_PRIVATE =  OBJECTPOINT + 103;

    CURLOPT_HTTP200ALIASES =  OBJECTPOINT + 104;

    CURLOPT_UNRESTRICTED_AUTH =  LONG + 105;

    CURLOPT_FTP_USE_EPRT =  LONG + 106;

    CURLOPT_SSL_CTX_FUNCTION =  FUNCTIONPOINT + 108;

    CURLOPT_SSL_CTX_DATA =  OBJECTPOINT + 109;

    CURLOPT_FTP_CREATE_MISSING_DIRS =  LONG + 110;

    CURLOPT_FTP_RESPONSE_TIMEOUT =  LONG + 112;
    CURLOPT_SERVER_RESPONSE_TIMEOUT = CURLOPT_FTP_RESPONSE_TIMEOUT;

    CURLOPT_IPRESOLVE =  LONG + 113;

    CURLOPT_MAXFILESIZE =  LONG + 114;

    CURLOPT_INFILESIZE_LARGE =  OFF_T + 115;

    CURLOPT_RESUME_FROM_LARGE =  FUNCTIONPOINT + 116;

    CURLOPT_MAXFILESIZE_LARGE =  FUNCTIONPOINT + 117;

    CURLOPT_NETRC_FILE =  OBJECTPOINT + 118;

    CURLOPT_USE_SSL =  LONG + 119;

    CURLOPT_POSTFIELDSIZE_LARGE =  FUNCTIONPOINT + 120;

    CURLOPT_TCP_NODELAY =  LONG + 121;


    CURLOPT_FTPSSLAUTH =  LONG + 129;

  CURLOPT_IOCTLFUNCTION =  FUNCTIONPOINT + 130;
  CURLOPT_IOCTLDATA =  OBJECTPOINT + 131;


    CURLOPT_FTP_ACCOUNT =  LONG + 134;

    CURLOPT_COOKIELIST =  LONG + 135;

    CURLOPT_IGNORE_CONTENT_LENGTH =  LONG + 136;

    CURLOPT_FTP_SKIP_PASV_IP =  LONG + 137;

    CURLOPT_FTP_FILEMETHOD =  LONG + 138;

    CURLOPT_LOCALPORT =  LONG + 139;

    CURLOPT_LOCALPORTRANGE =  LONG + 140;

    CURLOPT_CONNECT_ONLY =  LONG + 141;

    CURLOPT_CONV_FROM_NETWORK_FUNCTION =  FUNCTIONPOINT + 142;

    CURLOPT_CONV_TO_NETWORK_FUNCTION =  FUNCTIONPOINT + 143;

  CURLOPT_CONV_FROM_UTF8_FUNCTION =  FUNCTIONPOINT + 144;

      CURLOPT_MAX_SEND_SPEED_LARGE =  FUNCTIONPOINT + 145;
  CURLOPT_MAX_RECV_SPEED_LARGE =  FUNCTIONPOINT + 146;

    CURLOPT_FTP_ALTERNATIVE_TO_USER =  OBJECTPOINT + 147;

    CURLOPT_SOCKOPTFUNCTION =  FUNCTIONPOINT + 148;
  CURLOPT_SOCKOPTDATA =  OBJECTPOINT + 149;

  CURLOPT_SSL_SESSIONID_CACHE =  LONG + 150;

    CURLOPT_SSH_AUTH_TYPES =  LONG + 151;

    CURLOPT_SSH_PUBLIC_KEYFILE =  OBJECTPOINT + 152;
  CURLOPT_SSH_PRIVATE_KEYFILE =  OBJECTPOINT + 153;

    CURLOPT_FTP_SSL_CCC =  LONG + 154;

    CURLOPT_TIMEOUT_MS =  LONG + 155;
  CURLOPT_CONNECTTIMEOUT_MS =  LONG + 156;

  CURLOPT_HTTP_TRANSFER_DECODING =  LONG + 157;
  CURLOPT_HTTP_CONTENT_DECODING =  LONG + 158;

  CURLOPT_NEW_FILE_PERMS =  LONG + 159;
  CURLOPT_NEW_DIRECTORY_PERMS =  LONG + 160;

  CURLOPT_POSTREDIR =  LONG + 161;

    CURLOPT_SSH_HOST_PUBLIC_KEY_MD5 =  OBJECTPOINT + 162;

  CURLOPT_OPENSOCKETFUNCTION =  FUNCTIONPOINT + 163;
  CURLOPT_OPENSOCKETDATA =  OBJECTPOINT + 164;

    CURLOPT_COPYPOSTFIELDS =  OBJECTPOINT + 165;

    CURLOPT_PROXY_TRANSFER_MODE =  LONG + 166;

    CURLOPT_SEEKFUNCTION =  FUNCTIONPOINT + 167;
  CURLOPT_SEEKDATA =  OBJECTPOINT + 168;

    CURLOPT_CRLFILE =  OBJECTPOINT + 169;

    CURLOPT_ISSUERCERT =  LONG + 170;

    CURLOPT_ADDRESS_SCOPE =  LONG + 171;

  CURLOPT_CERTINFO =  LONG + 172;

    CURLOPT_USERNAME =  OBJECTPOINT + 173;
  CURLOPT_PASSWORD =  OBJECTPOINT + 174;

      CURLOPT_PROXYUSERNAME =  OBJECTPOINT + 175;
  CURLOPT_PROXYPASSWORD =  OBJECTPOINT + 176;


    CURLOPT_TFTP_BLKSIZE =  OBJECTPOINT + 178;

    CURLOPT_SOCKS5_GSSAPI_SERVICE =  OBJECTPOINT + 179;

    CURLOPT_SOCKS5_GSSAPI_NEC =  LONG + 180;

  CURLOPT_PROTOCOLS =  LONG + 181;

  CURLOPT_REDIR_PROTOCOLS =  LONG + 182;

    CURLOPT_SSH_KNOWNHOSTS =  OBJECTPOINT + 183;

  CURLOPT_SSH_KEYFUNCTION =  FUNCTIONPOINT + 184;

    CURLOPT_SSH_KEYDATA =  OBJECTPOINT + 185;

    CURLOPT_MAIL_FROM =  OBJECTPOINT + 186;

    CURLOPT_MAIL_RCPT =  OBJECTPOINT + 187;

    CURLOPT_FTP_USE_PRET =  LONG + 188;

    CURLOPT_RTSP_REQUEST =  LONG + 189;

    CURLOPT_RTSP_SESSION_ID =  OBJECTPOINT + 190;

    CURLOPT_RTSP_STREAM_URI =  OBJECTPOINT + 191;

    CURLOPT_RTSP_TRANSPORT =  OBJECTPOINT + 192;

    CURLOPT_RTSP_CLIENT_CSEQ =  LONG + 193;

    CURLOPT_RTSP_SERVER_CSEQ =  LONG + 194;

    CURLOPT_INTERLEAVEDATA =  OBJECTPOINT + 195;

    CURLOPT_INTERLEAVEFUNCTION =  FUNCTIONPOINT + 196;

    CURLOPT_WILDCARDMATCH =  LONG + 197;

  CURLOPT_CHUNK_BGN_FUNCTION =  FUNCTIONPOINT + 198;

  CURLOPT_CHUNK_END_FUNCTION =  FUNCTIONPOINT + 199;

    CURLOPT_FNMATCH_FUNCTION =  FUNCTIONPOINT + 200;

    CURLOPT_CHUNK_DATA =  OBJECTPOINT + 201;

    CURLOPT_FNMATCH_DATA =  OBJECTPOINT + 202;

    CURLOPT_RESOLVE =  OBJECTPOINT + 203;

    CURLOPT_TLSAUTH_USERNAME =  OBJECTPOINT + 204;

    CURLOPT_TLSAUTH_PASSWORD =  OBJECTPOINT + 205;

    CURLOPT_TLSAUTH_TYPE =  OBJECTPOINT + 206;

  CURLOPT_TRANSFER_ENCODING =  LONG + 207;

  CURLOPT_CLOSESOCKETFUNCTION =  FUNCTIONPOINT + 208;
  CURLOPT_CLOSESOCKETDATA =  LONG + 209;

    CURLOPT_GSSAPI_DELEGATION =  LONG + 210;

    CURLOPT_DNS_SERVERS =  OBJECTPOINT + 211;

  CURLOPT_ACCEPTTIMEOUT_MS =  LONG + 212;

  CURLOPT_TCP_KEEPALIVE = LONG + 213;
  CURLOPT_TCP_KEEPIDLE = LONG + 214;
  CURLOPT_TCP_KEEPINTVL = LONG + 215;

  CURLOPT_SSL_OPTIONS = LONG + 216;
  CURLOPT_MAIL_AUTH = OBJECTPOINT + 217;

    CURL_IPRESOLVE_WHATEVER = 0;

    CURL_IPRESOLVE_V4 = 1;

    CURL_IPRESOLVE_V6 = 2;


    type
      CURL_NETRC_OPTION = (CURL_NETRC_IGNORED,CURL_NETRC_OPTIONAL,
        CURL_NETRC_REQUIRED,CURL_NETRC_LAST
        );

      CURL_TLSAUTH = (CURL_TLSAUTH_NONE,CURL_TLSAUTH_SRP,
        CURL_TLSAUTH_LAST);

    const
      CURL_REDIR_GET_ALL = 0;
      CURL_REDIR_POST_301 = 1;
      CURL_REDIR_POST_302 = 2;
      CURL_REDIR_POST_303 = 4;
      CURL_REDIR_POST_ALL = CURL_REDIR_POST_301 or CURL_REDIR_POST_302 or CURL_REDIR_POST_303;

    type
      curl_TimeCond = (CURL_TIMECOND_NONE,CURL_TIMECOND_IFMODSINCE,
        CURL_TIMECOND_IFUNMODSINCE,CURL_TIMECOND_LASTMOD,
        CURL_TIMECOND_LAST);

    procedure curl_free(p:pointer);external {$IFDEF LINK_DYNAMIC}CurlLib{$ENDIF} name 'curl_free';

    function curl_global_init(flags:longint):CURLcode;external {$IFDEF LINK_DYNAMIC}CurlLib{$ENDIF} name 'curl_global_init';

    function curl_global_init_mem(flags:longint; m:curl_malloc_callback; f:curl_free_callback; r:curl_realloc_callback; s:curl_strdup_callback;
               c:curl_calloc_callback):CURLcode;external {$IFDEF LINK_DYNAMIC}CurlLib{$ENDIF} name 'curl_global_init_mem';

    procedure curl_global_cleanup;external {$IFDEF LINK_DYNAMIC}CurlLib{$ENDIF} name 'curl_global_cleanup';

    type
      curl_certinfo = record
          num_of_certs : longint;
          certinfo : ppcurl_slist;
        end;

    const
      CURLINFO_STRING = $100000;
      CURLINFO_LONG = $200000;
      CURLINFO_DOUBLE = $300000;
      CURLINFO_SLIST = $400000;
      CURLINFO_MASK = $0fffff;
      CURLINFO_TYPEMASK = $f00000;

    type
      CURLINFO = integer;
    const
      CURLINFO_NONE = 0;
      CURLINFO_EFFECTIVE_URL = CURLINFO_STRING+1;
      CURLINFO_RESPONSE_CODE = CURLINFO_LONG+2;
      CURLINFO_TOTAL_TIME = CURLINFO_DOUBLE+3;
      CURLINFO_NAMELOOKUP_TIME = CURLINFO_DOUBLE+4;
      CURLINFO_CONNECT_TIME = CURLINFO_DOUBLE+5;
      CURLINFO_PRETRANSFER_TIME = CURLINFO_DOUBLE+6;
      CURLINFO_SIZE_UPLOAD = CURLINFO_DOUBLE+7;
      CURLINFO_SIZE_DOWNLOAD = CURLINFO_DOUBLE+8;
      CURLINFO_SPEED_DOWNLOAD = CURLINFO_DOUBLE+9;
      CURLINFO_SPEED_UPLOAD = CURLINFO_DOUBLE+10;
      CURLINFO_HEADER_SIZE = CURLINFO_LONG+11;
      CURLINFO_REQUEST_SIZE = CURLINFO_LONG+12;
      CURLINFO_SSL_VERIFYRESULT = CURLINFO_LONG+13;
      CURLINFO_FILETIME = CURLINFO_LONG+14;
      CURLINFO_CONTENT_LENGTH_DOWNLOAD = CURLINFO_DOUBLE+15;
      CURLINFO_CONTENT_LENGTH_UPLOAD = CURLINFO_DOUBLE+16;
      CURLINFO_STARTTRANSFER_TIME = CURLINFO_DOUBLE+17;
      CURLINFO_CONTENT_TYPE = CURLINFO_STRING+18;
      CURLINFO_REDIRECT_TIME = CURLINFO_DOUBLE+19;
      CURLINFO_REDIRECT_COUNT = CURLINFO_LONG+20;
      CURLINFO_PRIVATE = CURLINFO_STRING+21;
      CURLINFO_HTTP_CONNECTCODE = CURLINFO_LONG+22;
      CURLINFO_HTTPAUTH_AVAIL = CURLINFO_LONG+23;
      CURLINFO_PROXYAUTH_AVAIL = CURLINFO_LONG+24;
      CURLINFO_OS_ERRNO = CURLINFO_LONG+25;
      CURLINFO_NUM_CONNECTS = CURLINFO_LONG+26;
      CURLINFO_SSL_ENGINES = CURLINFO_SLIST+27;
      CURLINFO_COOKIELIST = CURLINFO_SLIST+28;
      CURLINFO_LASTSOCKET = CURLINFO_LONG+29;
      CURLINFO_FTP_ENTRY_PATH = CURLINFO_STRING+30;
      CURLINFO_REDIRECT_URL = CURLINFO_STRING+31;
      CURLINFO_PRIMARY_IP = CURLINFO_STRING+32;
      CURLINFO_APPCONNECT_TIME = CURLINFO_DOUBLE+33;
      CURLINFO_CERTINFO = CURLINFO_SLIST+34;
      CURLINFO_CONDITION_UNMET = CURLINFO_LONG+35;
      CURLINFO_RTSP_SESSION_ID = CURLINFO_STRING+36;
      CURLINFO_RTSP_CLIENT_CSEQ = CURLINFO_LONG+37;
      CURLINFO_RTSP_SERVER_CSEQ = CURLINFO_LONG+38;
      CURLINFO_RTSP_CSEQ_RECV = CURLINFO_LONG+39;
      CURLINFO_PRIMARY_PORT = CURLINFO_LONG+40;
      CURLINFO_LOCAL_IP = CURLINFO_STRING+41;
      CURLINFO_LOCAL_PORT = CURLINFO_LONG+42;
      CURLINFO_LASTONE = 42;

      CURLINFO_HTTP_CODE = CURLINFO_RESPONSE_CODE;

    type
      curl_closepolicy = (CURLCLOSEPOLICY_NONE,CURLCLOSEPOLICY_OLDEST,
        CURLCLOSEPOLICY_LEAST_RECENTLY_USED,
        CURLCLOSEPOLICY_LEAST_TRAFFIC,CURLCLOSEPOLICY_SLOWEST,
        CURLCLOSEPOLICY_CALLBACK,CURLCLOSEPOLICY_LAST
        );

    const
      CURL_GLOBAL_SSL = 1 shl 0;
      CURL_GLOBAL_WIN32 = 1 shl 1;
      CURL_GLOBAL_ALL = CURL_GLOBAL_SSL or CURL_GLOBAL_WIN32;
      CURL_GLOBAL_NOTHING = 0;
      CURL_GLOBAL_DEFAULT = CURL_GLOBAL_ALL;

    type
      curl_lock_data = (CURL_LOCK_DATA_NONE,CURL_LOCK_DATA_SHARE,
        CURL_LOCK_DATA_COOKIE,CURL_LOCK_DATA_DNS,
        CURL_LOCK_DATA_SSL_SESSION,CURL_LOCK_DATA_CONNECT,
        CURL_LOCK_DATA_LAST);

      curl_lock_access = (CURL_LOCK_ACCESS_NONE,CURL_LOCK_ACCESS_SHARED,
        CURL_LOCK_ACCESS_SINGL,CURL_LOCK_ACCESS_LAST
        );

      curl_lock_function = procedure (handle:PCURL; data:curl_lock_data; locktype:curl_lock_access; userptr:pointer);

      curl_unlock_function = procedure (handle:PCURL; data:curl_lock_data; userptr:pointer);

    const
      CURLPAUSE_RECV = 1 shl 0;
      CURLPAUSE_RECV_CONT = 0;
      CURLPAUSE_SEND = 1 shl 2;
      CURLPAUSE_SEND_CONT = 0;
      CURLPAUSE_ALL = CURLPAUSE_RECV or CURLPAUSE_SEND;
      CURLPAUSE_CONT = CURLPAUSE_RECV_CONT or CURLPAUSE_SEND_CONT;

{$IFNDEF LIBCURL_MONOLITHIC}
implementation
end.
{$ENDIF}
