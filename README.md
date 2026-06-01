
How it works

Auto-detects your package manager on each run — just copy the same setup.sh to any distro and run it
Skips apps that are already installed, so it's safe to re-run
Aliases use a runtime _pm() helper, meaning update/install/remove will also work correctly on any distro after you hop — they detect the pm live, not at install time
Fish gets abbr (abbreviations) instead of aliases, which is the idiomatic fish way

A heads up for Fedora specifically — ffmpeg needs RPM Fusion enabled first. The script installs the package but if you're on a fresh Fedora without RPM Fusion you'll hit an error. Want me to add an RPM Fusion enablement step for the dnf path?
To use it:

chmod +x setup.sh
./setup.sh
source ~/.bashrc   # or restart shell
