#include "feedlist.h"
#include "feedlistthread.h"
#include "libr3r.h"
#include "subscriptions.h"

#include "i18n.h"

void * rlib;
FeedListView * feedList;
bool topItem = false;

int rargc;
wxChar ** rargv;

void normalize_field_value(char ** field_value)
{
  char * s = *field_value;

  if (0 == strlen(s))
  {
#if wxCHECK_VERSION(2,9,0)
		wxString t = _("[None]");
		s = (char *) malloc(t.Length() * sizeof(wxChar));
    strcpy(s, (char *) t.char_str());
#else
		const wxChar * t = _("[None]");
		s = (char *) malloc(wxStrlen(t) * sizeof(t));
		strcpy(s, wxString(t, wxConvUTF8).char_str());
#endif

		strcpy(*field_value, s);
		free(s);
  }
}

void item_parsed(void * item)
{
  static long itemIndex = 0;
  char * created = (char *) libr3r_get_item_field(item, (char *) "created");
  char * desc = (char *) libr3r_get_item_field(item, (char *) "description");
  char * subject = (char *) libr3r_get_item_field(item, (char *) "subject");
  char * title = (char *) libr3r_get_item_field(item, (char *) "title-text");

  normalize_field_value(&desc);

  ItemInfo * info = (ItemInfo *) malloc(sizeof(ItemInfo));
  info->isTopLevel = topItem;
  info->desc = desc;
  info->link = (char *) libr3r_get_item_field(item, (char *) "main-link");
  info->title = title;
  info->contact = (char *) libr3r_get_item_field(item, (char *) "contact-email");
  info->self = (char *) libr3r_get_item_field(item, (char *) "myself");
  info->podcast = (char *) libr3r_get_item_field(item, (char *) "podcast");

  wxListItem listItem;
  listItem.SetColumn(0);
  listItem.SetData(info);
  listItem.SetId(itemIndex);
  listItem.SetText(wxString(title, wxConvUTF8));

  if (topItem)
  {
    feedList->InsertItem(listItem);

    listItem.SetColumn(1);
    listItem.SetText(wxT(""));
    feedList->SetItem(listItem);
  }
  else
  {
    listItem.SetText(wxT(""));
    feedList->InsertItem(listItem);

    listItem.SetColumn(1);
    listItem.SetText(wxString(title, wxConvUTF8));
    feedList->SetItem(listItem);

    normalize_field_value(&created);
    normalize_field_value(&subject);
  }

  listItem.SetColumn(2);
  listItem.SetText(wxString(subject, wxConvUTF8));
  feedList->SetItem(listItem);

  listItem.SetColumn(3);
  listItem.SetText(wxString(created, wxConvUTF8));
  feedList->SetItem(listItem);

  topItem = false;
  itemIndex++;
}

void message_received(unsigned short int is_error, char * message_name, char * extra)
{
  int error_type = is_error ? wxICON_ERROR : wxICON_WARNING;

  wxMessageBox(wxString(message_name, wxConvUTF8), wxString(extra,wxConvUTF8), wxOK | error_type);
}

void update_available()
{
  if (wxMessageBox(_("An update is available."), wxT(""), wxOK | wxCANCEL) == wxOK)
  {
    GoBrowser((char *) "http://sourceforge.net/projects/r3r");
  }
}

void CreateFeedList(wxPanel * parent)
{
  InitGettext();

  wxListItem listItem;
  wxSizer * sizer = parent->GetSizer();

  feedList = new FeedListView(parent, -1, wxDefaultPosition, wxDefaultSize, wxLC_REPORT | wxLC_SINGLE_SEL);

  listItem.SetText(_("Feed Title"));
  feedList->InsertColumn(0, listItem);

  listItem.SetText(_("Item Title"));
  feedList->InsertColumn(1, listItem);

  listItem.SetText(_("Subject"));
  feedList->InsertColumn(2, listItem);

  listItem.SetText(_("Date Created"));
  feedList->InsertColumn(3, listItem);

  sizer->Add(feedList, 2, wxEXPAND, 10);

  rlib = libr3r_create();
  libr3r_on_item_parsed(rlib, &item_parsed);
  libr3r_on_message_received(rlib, &message_received);
  libr3r_on_update(rlib, &update_available);

  feedList->SetClientData(rlib);
}

FeedListView * GetFeedList()
{
  return feedList;
}

void * ParseFeedThread(void * resource)
{
  FeedResource * res = (FeedResource *) resource;

  topItem = true;

  libr3r_retrieve_feed(res->lib, res->res);
  free(res);

  return NULL;
}

void ParseFeed(char * res)
{
  FeedResource * resource = (FeedResource *) malloc(sizeof(FeedResource));
  resource->lib = rlib;
  resource->res = res;

	FeedListThread * thread = new FeedListThread(wxTHREAD_JOINABLE);
	thread->SetEntryData(resource);

	if (wxTHREAD_NO_ERROR == thread->Create())
	{
		thread->Run();
	}
	else
	{
		ParseFeedThread(resource);
	}

	if (thread->IsDetached())
	{
		thread->Delete();
	}
	else
	{
		thread->Wait();
		delete thread;
	}
}

void GetAllFeeds(int argc, wxChar ** argv)
{
  char * name, * s;
  int count, i, index;
  unsigned char type;
  void * value;

  if (argv)
  {
    rargc = argc;
    rargv = argv;
  }

  for (i = 1; i < rargc; i++)
  {
    ParseFeed((char *) (const char *) wxString(rargv[i], wxConvUTF8).mb_str());
  }

  index = 0;
  name = (char *) "load-subscriptions-on-startup";
  libr3r_access_settings(&index, &name, &value, &type, &count, SETTINGS_READ);

  if ((bool) value)
  {
    Subscriptions * subs = GetSubscriptionsObject();
    while ((s = subs->GetNext()) != NULL)
    {
      ParseFeed(s);
    }
  }
}

void GoBrowser(char * url)
{
  char * name;
  int count, index;
  unsigned char type;
  void * value;
  wxString browser, command, URL;

  index = 0;
  name = (char *) "for:http";
  libr3r_access_settings(&index, &name, &value, &type, &count, SETTINGS_READ);

  browser = wxString((char *) value, wxConvUTF8);
  URL = wxString(url, wxConvUTF8);

  if (wxNOT_FOUND == browser.Find(wxT("%1")))
  {
    command = browser + wxT(" ") + wxT("\"") + URL + wxT("\"");
  }
  else
  {
    browser.Replace(wxT("%1"), URL);
    URL.Clear();
    command = browser;
  }

  wxExecute(command);
}

void SendOwnMessage(unsigned char is_error, char * message, char * extra)
{
#if wxCHECK_VERSION(2,9,0)
	wxString hint = _("\n\n[Disable messages (in your settings) to not see this again.]");
#endif

  bool show_messages;
  int count, index;
  char * name;
  unsigned char type;
  void * value;

  index = 0;
  name = (char *) "show-messages";
  libr3r_access_settings(&index, &name, &value, &type, &count, SETTINGS_READ);
  show_messages = (bool) value;

	char * msg;
#if wxCHECK_VERSION(2,9,0)
	msg = (char *) malloc(sizeof(char) * (strlen(message) + strlen(hint.char_str())));
#else
	msg = (char *) malloc(sizeof(char) * strlen(message));
#endif
	strcpy(msg, message);
	
#if wxCHECK_VERSION(2,9,0)
	strcat(msg,hint.char_str());
#endif

  if (show_messages)
  {
    message_received(is_error, msg, extra);
  }
}
