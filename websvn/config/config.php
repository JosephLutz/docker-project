<?php
$config->addTemplatePath($locwebsvnreal."/templates/calm/");
$config->addTemplatePath($locwebsvnreal."/templates/BlueGrey/");
$config->addTemplatePath($locwebsvnreal."/templates/Elegant/");

$config->useTreeIndex(false); // Tree index, closed by default
// $config->useTreeIndex(true); // Tree index, open by default
$config->useFlatView(); // load faster
// $config->setIgnoreWhitespacesInDiff(true);

// $config->useAuthenticationFile("/path/to/accessfile"); // Global access file
// $config->useAuthenticationFile("/path/to/accessfile", "myrep"); // Access file for myrep

$config->setRssMaxEntries(25);
// $config->setRssMaxEntries(50, "myrep");


// {{{ BUGTRAQ ---
// Uncomment this line to use bugtraq: properties to show links to your BugTracker
// from log messages.
// $config->setBugtraqEnabled(true);
// To override the global setting for individual repositories, uncomment and replicate
// the appropriate line below (replacing 'myrep' with the name of the repository).
// Use the convention 'groupname.myrep' if your repository is in a group.
// $config->setBugtraqEnabled(true,  'myrep');
// $config->setBugtraqEnabled(false, 'myrep');
// Usually the information to extract the bugtraq information and generate links are
// stored in SVN properties starting with 'bugtraq:':
// namely 'bugtraq:message', 'bugtraq:logregex', 'bugtraq:url' and 'bugtraq:append'.
// To override the SVN properties globally or for individual repositories, uncomment
// the appropriate line below (replacing 'myrep' with the name of the repository).
// $config->setBugtraqProperties('bug #%BUGID%', 'issues? (\d+)([, ] *(\d+))*'."\n".'(\d+)', 'http://www.example.com/issues/s    how_bug.cgi?id=%BUGID%', false);
// $config->setBugtraqProperties('bug #%BUGID%', 'issues? (\d+)([, ] *(\d+))*'."\n".'(\d+)', 'http://www.example.com/issues/s    how_bug.cgi?id=%BUGID%', false, 'myrep');
// }}}

// {{{ PLATFORM CONFIGURATION ---
// Configure the path for Subversion to use for --config-dir
// (e.g. if accepting certificates is required when using repositories via https)
// $config->setSvnConfigDir("/tmp");
// Uncomment this line to trust server certificates
// This may useful if you use self-signed certificates and have no chance to accept the certificate once via cli
// $config->setTrustServerCert();
// }}}

$config->useEnscript();
$config->setEnscriptPath("/usr/bin");
$config->setSedPath("/bin");

# $config->setShowAgeInsteadOfDate(false);

$config->expandTabsBy(8);
$config->setBlockRobots();
set_time_limit(0);

$config->parentPath("SVN_BASE_DIR");

?>
