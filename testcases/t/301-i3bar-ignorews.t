#!perl
# vim:ts=4:sw=4:expandtab
#
# Please read the following documents before working on tests:
# • https://build.i3wm.org/docs/testsuite.html
#   (or docs/testsuite)
#
# • https://build.i3wm.org/docs/lib-i3test.html
#   (alternatively: perldoc ./testcases/lib/i3test.pm)
#
# • https://build.i3wm.org/docs/ipc.html
#   (or docs/ipc)
#
# • http://onyxneon.com/books/modern_perl/modern_perl_a4.pdf
#   (unless you are already familiar with Perl)
#
# TODO: Description of this file.
# Ticket: #999

use i3test i3_config => <<'EOT';
# i3 config file (v4)
font -misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1

bar {
    font -misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1
    position top

    ignore_ws "(IGNORED|^5$|^\d+: WS_NAME)"
}
EOT
use i3test::XTEST;

# Get the i3bar window
my @docked = get_dock_clients('top');
if (@docked == 0) {
    AnyEvent->condvar->recv;
    @docked = get_dock_clients('top');
}
my $i3bar_window = $docked[0]->{window};
diag('i3bar window = ' . $i3bar_window);

cmd 'workspace ZZZtarget';
open_window;

sub do_test {
    my ($ws_name, $ignored) = @_;

    cmd "workspace $ws_name";
    sync_with_i3;

    xtest_button_press(1, 0, 0);
    xtest_button_release(1, 0, 0);
    xtest_sync_with_i3;
    xtest_sync_with($i3bar_window);

    if ($ignored) {
        is(focused_ws, 'ZZZtarget', "workspace '$ws_name' ignored");
    } else {
        is(focused_ws, $ws_name, "workspace '$ws_name' focused");
        # Now close the empty workspace
        cmd 'workspace ZZZtarget';
    }
}

do_test('1: IGNORED', 1);
do_test('xxxIGNOREDxxx', 1);
do_test('5', 1);
do_test('55', 0);
do_test('3', 0);
do_test('2: WS_NAME', 1);

done_testing;
