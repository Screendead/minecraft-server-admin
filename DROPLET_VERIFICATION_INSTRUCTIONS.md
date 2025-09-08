# Droplet Verification Instructions

This document provides step-by-step instructions for verifying that a newly created Minecraft server droplet is working correctly.

## Prerequisites

- Root access to the droplet via SSH or DigitalOcean console
- Basic familiarity with Linux command line

## Verification Steps

### 1. Check Cloud-Init Status

```bash
cloud-init status
```

**Expected Result:** `status: done` (not `running` or `error`)

### 2. Check Cloud-Init Logs

```bash
cat /var/log/cloud-init-output.log
```

**Look for:**
- ✅ No YAML parsing errors
- ✅ Java installation completed
- ✅ Minecraft user created
- ✅ Server JAR downloaded
- ✅ server.properties file created
- ✅ systemd service enabled and started

### 3. Verify Minecraft User and Directory

```bash
id minecraft
ls -la /opt/minecraft/
```

**Expected Results:**
- ✅ `minecraft` user exists
- ✅ `/opt/minecraft/` directory exists and is owned by `minecraft:minecraft`

### 4. Check Server Files

```bash
ls -la /opt/minecraft/
cat /opt/minecraft/server.properties
```

**Expected Results:**
- ✅ `server.jar` file downloaded
- ✅ `eula.txt` file with `eula=true`
- ✅ `server.properties` with correct settings for your RAM

### 5. Check Systemd Service

```bash
systemctl status minecraft-server
systemctl is-enabled minecraft-server
```

**Expected Results:**
- ✅ Service is `active (running)`
- ✅ Service is `enabled`

### 6. Check Server Logs

```bash
journalctl -u minecraft-server -f
```

**Expected Results:**
- ✅ Server starting up
- ✅ No Java errors
- ✅ Server ready for connections

### 7. Check Firewall

```bash
ufw status
```

**Expected Results:**
- ✅ Port 25565 (Minecraft) allowed
- ✅ Port 25575 (RCON) allowed

### 8. Test Server Connection

```bash
netstat -tlnp | grep 25565
```

**Expected Result:** Server listening on port 25565

### 9. Check Memory Allocation

```bash
cat /opt/minecraft/server.properties | grep -E "(view-distance|simulation-distance)"
```

**Expected Results (based on RAM):**
- **512MB RAM**: view-distance=6, simulation-distance=4
- **1GB RAM**: view-distance=8, simulation-distance=6
- **2GB RAM**: view-distance=10, simulation-distance=8
- **4GB+ RAM**: Higher values (12-16 view distance)

### 10. Check JVM Memory Settings

```bash
ps aux | grep java
```

**Expected Result:** Java process with `-Xmx` and `-Xms` flags matching your calculated memory allocation

## Success Indicators

- No YAML parsing errors in cloud-init logs
- Minecraft user and directory created
- Server JAR downloaded successfully
- systemd service running
- Firewall ports open
- Server listening on port 25565

## Failure Indicators

- YAML parsing errors in cloud-init logs
- Missing minecraft user or directory
- systemd service failed to start
- Java process not running
- Server not listening on port 25565

## Troubleshooting

### If Cloud-Init Failed

1. Check the full cloud-init log:
   ```bash
   cat /var/log/cloud-init-output.log | tail -50
   ```

2. Look for specific error messages and address them

3. If YAML parsing errors persist, the cloud-init script may need to be updated

### If Minecraft Service Failed

1. Check service status:
   ```bash
   systemctl status minecraft-server
   ```

2. Check service logs:
   ```bash
   journalctl -u minecraft-server --no-pager
   ```

3. Restart the service:
   ```bash
   systemctl restart minecraft-server
   ```

### If Server Won't Start

1. Check Java installation:
   ```bash
   java -version
   ```

2. Check server JAR:
   ```bash
   ls -la /opt/minecraft/server.jar
   ```

3. Try running manually:
   ```bash
   cd /opt/minecraft
   sudo -u minecraft java -Xmx1024M -Xms1024M -jar server.jar nogui
   ```

## Connection Information

Once verified, your Minecraft server should be accessible at:
- **IP Address**: Check droplet's public IP in DigitalOcean dashboard
- **Port**: 25565 (default Minecraft port)
- **RCON Port**: 25575 (for server administration)

## Next Steps

After successful verification:
1. Connect to your server using a Minecraft client
2. Configure additional server settings in `/opt/minecraft/server.properties`
3. Set up regular backups of your world data
4. Consider setting up monitoring and alerting
