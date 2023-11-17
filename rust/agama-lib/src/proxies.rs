//! D-Bus interface proxies for: `org.opensuse.Agama*.**.*`
//!
//! This code was generated by `zbus-xmlgen` `3.1.0` from DBus introspection data.`.
use zbus::dbus_proxy;

/// Progress1Proxy can be used also with Software and Storage object.
///
/// TODO: example
#[dbus_proxy(
    interface = "org.opensuse.Agama1.Progress",
    default_service = "org.opensuse.Agama.Manager1",
    default_path = "/org/opensuse/Agama/Manager1"
)]
trait Progress {
    /// CurrentStep property
    #[dbus_proxy(property)]
    fn current_step(&self) -> zbus::Result<(u32, String)>;

    /// Finished property
    #[dbus_proxy(property)]
    fn finished(&self) -> zbus::Result<bool>;

    /// TotalSteps property
    #[dbus_proxy(property)]
    fn total_steps(&self) -> zbus::Result<u32>;
}

#[dbus_proxy(
    interface = "org.opensuse.Agama1.ServiceStatus",
    default_service = "org.opensuse.Agama.Manager1",
    default_path = "/org/opensuse/Agama/Manager1"
)]
trait ServiceStatus {
    /// All property
    #[dbus_proxy(property)]
    fn all(
        &self,
    ) -> zbus::Result<Vec<std::collections::HashMap<String, zbus::zvariant::OwnedValue>>>;

    /// Current property
    #[dbus_proxy(property)]
    fn current(&self) -> zbus::Result<u32>;
}

#[dbus_proxy(
    interface = "org.opensuse.Agama.Manager1",
    default_service = "org.opensuse.Agama.Manager1",
    default_path = "/org/opensuse/Agama/Manager1"
)]
trait Manager {
    /// CanInstall method
    fn can_install(&self) -> zbus::Result<bool>;

    /// CollectLogs method
    fn collect_logs(&self, user: &str) -> zbus::Result<String>;

    /// Commit method
    fn commit(&self) -> zbus::Result<()>;

    /// Probe method
    fn probe(&self) -> zbus::Result<()>;

    /// BusyServices property
    #[dbus_proxy(property)]
    fn busy_services(&self) -> zbus::Result<Vec<String>>;

    /// CurrentInstallationPhase property
    #[dbus_proxy(property)]
    fn current_installation_phase(&self) -> zbus::Result<u32>;

    /// InstallationPhases property
    #[dbus_proxy(property)]
    fn installation_phases(
        &self,
    ) -> zbus::Result<Vec<std::collections::HashMap<String, zbus::zvariant::OwnedValue>>>;
}

#[dbus_proxy(interface = "org.opensuse.Agama1.Locale", assume_defaults = true)]
trait Locale {
    /// Commit method
    fn commit(&self) -> zbus::Result<()>;

    /// ListLocales method
    fn list_locales(&self) -> zbus::Result<Vec<(String, (String, String), (String, String))>>;

    /// ListTimezones method
    fn list_timezones(&self, locale: &str) -> zbus::Result<Vec<(String, String)>>;

    /// ListVConsoleKeyboards method
    #[dbus_proxy(name = "ListVConsoleKeyboards")]
    fn list_vconsole_keyboards(&self) -> zbus::Result<Vec<String>>;

    /// Locales property
    #[dbus_proxy(property)]
    fn locales(&self) -> zbus::Result<Vec<String>>;
    fn set_locales(&self, value: &[&str]) -> zbus::Result<()>;

    /// SupportedLocales property
    #[dbus_proxy(property)]
    fn supported_locales(&self) -> zbus::Result<Vec<String>>;
    fn set_supported_locales(&self, value: &[&str]) -> zbus::Result<()>;

    /// Timezone property
    #[dbus_proxy(property)]
    fn timezone(&self) -> zbus::Result<String>;
    fn set_timezone(&self, value: &str) -> zbus::Result<()>;

    /// VConsoleKeyboard property
    #[dbus_proxy(property, name = "VConsoleKeyboard")]
    fn vconsole_keyboard(&self) -> zbus::Result<String>;
    fn set_vconsole_keyboard(&self, value: &str) -> zbus::Result<()>;
}

#[dbus_proxy(
    interface = "org.opensuse.Agama1.Questions",
    default_service = "org.opensuse.Agama1",
    default_path = "/org/opensuse/Agama1/Questions"
)]
trait Questions1 {
    /// AddAnswerFile method
    fn add_answer_file(&self, path: &str) -> zbus::Result<()>;

    /// Delete method
    fn delete(&self, question: &zbus::zvariant::ObjectPath<'_>) -> zbus::Result<()>;

    /// New method
    #[dbus_proxy(name = "New")]
    fn new_quetion(
        &self,
        class: &str,
        text: &str,
        options: &[&str],
        default_option: &str,
        data: std::collections::HashMap<&str, &str>,
    ) -> zbus::Result<zbus::zvariant::OwnedObjectPath>;

    /// NewWithPassword method
    fn new_with_password(
        &self,
        class: &str,
        text: &str,
        options: &[&str],
        default_option: &str,
        data: std::collections::HashMap<&str, &str>,
    ) -> zbus::Result<zbus::zvariant::OwnedObjectPath>;

    /// Interactive property
    #[dbus_proxy(property)]
    fn interactive(&self) -> zbus::Result<bool>;
    #[dbus_proxy(property)]
    fn set_interactive(&self, value: bool) -> zbus::Result<()>;
}
