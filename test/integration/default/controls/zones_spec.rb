# frozen_string_literal: true

control 'zones/public.xml configuration' do
  title 'should match desired lines'

  describe file('/etc/firewalld/zones/public.xml') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('content') do
      should include <<~ZONE_XML
        <zone>
          <short>Public</short>
          <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
          <service name="zabbixcustom" />
          <service name="http" />
          <service name="https" />
          <service name="ssh" />
          <service name="salt-minion" />
          <!-- zabbix-agent -->
          <port port="10050" protocol="tcp" />
          <!-- bacula-client -->
          <port port="9102" protocol="tcp" />
          <!-- vsftpd -->
          <port port="21" protocol="tcp" />
          <protocol value="igmp" />
          <!-- something -->
          <source-port port="2222" protocol="tcp" />
          <!-- something_else -->
          <source-port port="4444" protocol="tcp" />
          <rule family="ipv4">
            <source address="8.8.8.8/24" />
            <accept></accept>
          </rule>
          <rule family="ipv4">
            <source ipset="fail2ban-ssh" />
            <reject type="icmp-port-unreachable" />
          </rule>
          <rule>
            <service name="http" />
            <log prefix="http fw limit 3/m" level="warning">
              <limit value="3/m"/>
            </log>
            <accept> <limit value="3/m"/></accept>
          </rule>
        </zone>
      ZONE_XML
    end
  end
end

control 'zones/rich_public.xml configuration' do
  title 'should match desired lines'

  describe file('/etc/firewalld/zones/rich_public.xml') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('content') do
      should include <<~ZONE_XML
        <zone>
          <short>rich_public</short>
          <description>Example</description>
          <rule>
            <source ipset="fail2ban-ssh" />
            <service name="ssh" />
            <accept></accept>
          </rule>
          <rule>
            <source ipset="other-ipset" />
            <service name="ssh" />
            <accept></accept>
          </rule>
        </zone>
      ZONE_XML
    end
  end
end
