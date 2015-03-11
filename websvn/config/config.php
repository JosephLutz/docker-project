<?php
$config->addTemplatePath($locwebsvnreal."/templates/calm/");
$config->addTemplatePath($locwebsvnreal."/templates/BlueGrey/");
$config->addTemplatePath($locwebsvnreal."/templates/Elegant/");

// $config->useTreeIndex(false); // Tree index, closed by default
// $config->useTreeIndex(true); // Tree index, open by default
// $config->useFlatView(); // load faster
// $config->setIgnoreWhitespacesInDiff(true);

// $config->useMultiViews();

// $config->useAuthenticationFile("/path/to/accessfile"); // Global access file
// $config->useAuthenticationFile("/path/to/accessfile", "myrep"); // Access file for myrep

$config->allowDownload();
// $config->allowDownload("myrep"); // Specifically allow downloading for "myrep"
$config->setDefaultFileDlMode("plain");
$config->setDefaultFolderDlMode("gzip");
$config->setMinDownloadLevel(2);
// $config->setMinDownloadLevel(2, "myrep");
// $config->addAllowedDownloadException("/path/to/allowed/directory/", "myrep");
// $config->addDisAllowedDownloadException("/path/to/disallowed/directory/", "myrep");

$config->setRssMaxEntries(50);
// $config->setRssMaxEntries(50, "myrep");

// Usually the information to extract the bugtraq information and generate links are
// stored in SVN properties starting with "bugtraq:":
// namely "bugtraq:message", "bugtraq:logregex", "bugtraq:url" and "bugtraq:append".
// To override the SVN properties globally or for individual repositories, uncomment
// the appropriate line below (replacing "myrep" with the name of the repository).
// $config->setBugtraqEnabled(true);
// $config->setBugtraqProperties("bug #%BUGID%", "issues? (\d+)([, ] *(\d+))*"."\n"."(\d+)", "http://www.example.com/issues/show_bug.cgi?id=%BUGID%", false);
// $config->setBugtraqProperties("bug #%BUGID%", "issues? (\d+)([, ] *(\d+))*"."\n"."(\d+)", "http://www.example.com/issues/show_bug.cgi?id=%BUGID%", false, "myrep");

// $config->setTrustServerCert();
// $config->setSvnConfigDir("/tmp");

// $config->setSVNCommandPath("Path/to/svn/command/"); //  e.g. c:\\program files\\subversion\\bin
// $config->setDiffPath("Path/to/diff/command/");
$config->setSedPath("/bin");
// $config->setTarPath("Path/to/tar/command/");
// $config->setGZipPath("Path/to/gzip/command/");
// $config->setZipPath("Path/to/zip/command/");

$config->useEnscript();
$config->setEnscriptPath("/usr/bin");
// $extEnscript[".pas"] = "pascal";
// $config->useGeshi();
// $extGeshi["pascal"] = array("p", "pas");

$config->expandTabsBy(8);
$config->setBlockRobots();
set_time_limit(0);

$config->parentPath("SVN_BASE_DIR");

?>
