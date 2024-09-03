using System;
using System.IO;
using System.Management.Automation;
using System.Collections.ObjectModel;
using System.Collections.Generic;
using System.Globalization;

#nullable enable

namespace HardenWindowsSecurity
{
    public class WindowsFirewall
    {
        /// <summary>
        /// Runs the Windows Firewall hardening category
        /// </summary>
        /// <exception cref="System.ArgumentNullException"></exception>
        public static void Invoke()
        {
            if (HardenWindowsSecurity.GlobalVars.path == null)
            {
                throw new System.ArgumentNullException("GlobalVars.path cannot be null.");
            }

            HardenWindowsSecurity.Logger.LogMessage("Running the Windows Firewall category");
            HardenWindowsSecurity.LGPORunner.RunLGPOCommand(System.IO.Path.Combine(HardenWindowsSecurity.GlobalVars.path, "Resources", "Security-Baselines-X", "Windows Firewall Policies", "registry.pol"), LGPORunner.FileType.POL);

            HardenWindowsSecurity.Logger.LogMessage("Disabling Multicast DNS (mDNS) UDP-in Firewall Rules for all 3 Firewall profiles - disables only 3 rules");


            HardenWindowsSecurity.PowerShellExecutor.ExecuteScript("""
Get-NetFirewallRule |
Where-Object -FilterScript { ($_.RuleGroup -eq '@%SystemRoot%\system32\firewallapi.dll,-37302') -and ($_.Direction -eq 'inbound') } |
ForEach-Object -Process { Disable-NetFirewallRule -DisplayName $_.DisplayName }
""");

        }
    }
}