#include "wx.h"

class FeedListView : public wxListView
{
	public:
		FeedListView(wxWindow * parent, wxWindowID id, const wxPoint & pos, const wxSize & size, long style);
		void ResizeColumns(int w);

	DECLARE_EVENT_TABLE();
};
