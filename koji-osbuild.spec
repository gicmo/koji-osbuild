%global         forgeurl https://github.com/gicmo/koji-osbuild

Name:           koji-osbuild
Version:        1
Release:        1%{?dist}
Summary:        Koji integration for osbuild composer

%forgemeta

License:        ASL 2.0
URL:            %{forgeurl}
Source0:        %{forgesource}

BuildArch:      noarch
BuildRequires:  python%{python3_pkgversion}-devel
BuildRequires:  python%{python3_pkgversion}dist(setuptools)

%description
Koji integration for osbuild composer.

%package        hub
Summary:        Koji hub plugin for osbuild composer integration
Requires:       %{name} = %{version}-%{release}
Requires:       koji-hub

%description    hub
Koji hub plugin for osbuild composer integration.

%package        builder
Summary:        Koji hub plugin for osbuild composer integration
Requires:       %{name} = %{version}-%{release}
Requires:       koji-builder

%description    builder
Koji builder plugin for osbuild composer integration.


%prep
%forgesetup

%build
# no op

%install
install -d %{buildroot}/%{_prefix}/lib/koji-hub-plugins
install -p -m 0755 plugins/hub/osbuild.py %{buildroot}/%{_prefix}/lib/koji-hub-plugins/
%py_byte_compile %{__python3} %{buildroot}/%{_prefix}/lib/koji-hub-plugins/osbuild.py

install -d %{buildroot}/%{_prefix}/lib/koji-builder-plugins
install -p -m 0755 plugins/builder/osbuild.py %{buildroot}/%{_prefix}/lib/koji-builder-plugins/
%py_byte_compile %{__python3} %{buildroot}/%{_prefix}/lib/koji-builder-plugins/osbuild.py

%files
%license LICENSE
%doc README.md

%files hub
%pycached %{_prefix}/lib/koji-hub-plugins/osbuild.py


%files builder
%pycached %{_prefix}/lib/koji-builder-plugins/osbuild.py


%changelog
# no change in upstream spec file