Name:           Mono_ASP.NET_Forums
Version:        0.7
Release:        1
License:        Shared Source License for ASP.NET Source Projects
Source:         monoforums-1_0_7.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  mono-web mono-data-postgresql xsp
BuildArch:      noarch  
Group:          Mono/ASP.NET
Summary:        ASP.NET Forums for ASP.NET 1.1 and PostgreSQL

%define aspPrefix /usr/share/mono/asp.net  
%define appsPrefix %{aspPrefix}/apps  
%define appsDataPrefix %{aspPrefix}/data  
%define appLocation %{appsPrefix}/%{name}
%define appDataLocation %{appsDataPrefix}/%{name}
%define appVirtualPath /AspNetForums
%define appInstanceName ASP.NET Forums
  
%define xspConfigsLocation /etc/xsp/1.0  
%define xspAvailableApps %{xspConfigsLocation}/applications-available  
%define xspEnabledApps %{xspConfigsLocation}/applications-enabled  

%description
These forums are a port of the original ASP.NET Forums from http://www.asp.net/Forums/. The principal features of this version of the Forums are that it adds support for Mono, and uses PostgreSQL for the database, so that it can be run entirely on Linux.

%prep
%setup -q -n AspNetForums

%clean
rm -rf "$RPM_BUILD_ROOT"

%files
%defattr(-, root, root)
%{appLocation}
%{appDataLocation}
%{xspConfigsLocation}

%install
install -d -m 755 $RPM_BUILD_ROOT%{appLocation}  
install -d -m 755 $RPM_BUILD_ROOT%{appDataLocation}  
install -d -m 755 $RPM_BUILD_ROOT%{xspAvailableApps}  
install -d -m 755 $RPM_BUILD_ROOT%{xspEnabledApps}  
  
mv ./*.sql $RPM_BUILD_ROOT%{appDataLocation}/  
mv ./init.sh $RPM_BUILD_ROOT%{appDataLocation}/init  
  
cp -rap ./* $RPM_BUILD_ROOT%{appLocation}/  
  
echo "<web-application>" >> $RPM_BUILD_ROOT%{xspAvailableApps}/%{name}.webapp  
echo "  <name>%{appInstanceName}</name>" >> $RPM_BUILD_ROOT%{xspAvailableApps}/%{name}.webapp  
echo "  <vpath>%{appVirtualPath}</vpath>" >> $RPM_BUILD_ROOT%{xspAvailableApps}/%{name}.webapp  
echo "  <path>%{appLocation}/AspNetForums</path>" >> $RPM_BUILD_ROOT%{xspAvailableApps}/%{name}.webapp  
echo "  <enabled>true</enabled>" >> $RPM_BUILD_ROOT%{xspAvailableApps}/%{name}.webapp
echo "</web-application>" >> $RPM_BUILD_ROOT%{xspAvailableApps}/%{name}.webapp

