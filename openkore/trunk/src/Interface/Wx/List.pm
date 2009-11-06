package Interface::Wx::List;

use strict;
use base 'Wx::Panel';
use Wx ':everything';
use Wx::Event qw/EVT_MENU EVT_LIST_ITEM_SELECTED EVT_LIST_ITEM_DESELECTED EVT_LIST_ITEM_ACTIVATED EVT_LIST_ITEM_RIGHT_CLICK/;

use constant {
	BORDER => 2,
};

# these wx constants are missing for a mysterious reason
use constant {
	wxLIST_NEXT_ABOVE => 0,
	wxLIST_NEXT_ALL => 1,
	wxLIST_NEXT_BELOW => 2,
	wxLIST_NEXT_LEFT => 3,
	wxLIST_NEXT_RIGHT => 4,
};

use constant {
	wxLIST_STATE_DONTCARE       => 0x0000,
	wxLIST_STATE_DROPHILITED    => 0x0001,      # MSW only
	wxLIST_STATE_FOCUSED        => 0x0002,
	wxLIST_STATE_SELECTED       => 0x0004,
	wxLIST_STATE_CUT            => 0x0008,      # MSW only
	wxLIST_STATE_DISABLED       => 0x0010,      # OS2 only
	wxLIST_STATE_FILTERED       => 0x0020,      # OS2 only
	wxLIST_STATE_INUSE          => 0x0040,      # OS2 only
	wxLIST_STATE_PICKED         => 0x0080,      # OS2 only
	wxLIST_STATE_SOURCE         => 0x0100,      # OS2 only
};

sub new {
	my ($class, $parent, $id) = @_;
	
	my $self = $class->SUPER::new ($parent, $id);
	
	$self->SetSizer (my $vsizer = new Wx::BoxSizer (wxVERTICAL));
	
	$vsizer->Add ($self->{list} = new Wx::ListCtrl (
		$self, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLC_REPORT | wxLC_HRULES
	), 1, wxGROW);
	
	$self->{list}->InsertColumn (0, '');
	$self->{list}->InsertColumn (1, '');
	$self->{list}->InsertColumn (2, '');
	$self->{list}->SetColumnWidth (0, 26);
	$self->{list}->SetColumnWidth (1, 50);
	$self->{list}->SetColumnWidth (2, 320);
	
	EVT_LIST_ITEM_SELECTED ($self, $self->{list}->GetId, sub { $self->_onSelectionChange; });
	EVT_LIST_ITEM_DESELECTED ($self, $self->{list}->GetId, sub { $self->_onSelectionChange; });
	EVT_LIST_ITEM_ACTIVATED ($self, $self->{list}->GetId, sub { $self->_onActivate; });
	EVT_LIST_ITEM_RIGHT_CLICK ($self, $self->{list}->GetId, sub { $self->_onRightClick; });
	
	$vsizer->Add ($self->{buttonSizer} = new Wx::FlexGridSizer (1, 0, BORDER, BORDER), 0, wxGROW);
	
	return $self;	
}

sub contextMenu {
	my ($self, $items) = @_;
	
	my $menu;
	
	if (@$items) {
		my $item = shift @$items;
		$menu = new Wx::Menu ($item->{title});
	} else {
		$menu = new Wx::Menu;
	}
	
	foreach (@$items) {
		EVT_MENU ($menu, $menu->Append (wxID_ANY, $_->{title})->GetId, $_->{callback});
	}
	
	$self->PopupMenu ($menu, wxDefaultPosition);
}

sub _onSelectionChange {
	my ($self) = @_;
	
	my $i = -1;
	$self->{selection} = [];
	
	while (1) {
		last if -1 == ($i = $self->{list}->GetNextItem ($i, wxLIST_NEXT_ALL, wxLIST_STATE_SELECTED));
		push @{$self->{selection}}, $self->{list}->GetItemData ($i);
	}
}

sub _onActivate {}
sub _onRightClick {}

1;