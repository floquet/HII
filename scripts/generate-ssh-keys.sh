#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# -----------------------------------------------------------------------------
# SSH Key Generation Script
# Generates both RSA-4096 (backward-compatible) and Ed25519 (modern) keys.
# Sets passphrase encryption and enforces security best practices.
# -----------------------------------------------------------------------------

# --- User Configuration ---
EMAIL="john.beighle@spaceforce.mil"  # Key comment (identifies owner)
PASSPHRASE="john.beighle"           # Passphrase for private keys (change in prod!)

# --- Key Generation ---

# 1. Generate Ed25519 Key (Recommended for Modern Systems)
# Flags:
#   -t ed25519 → Use Ed25519 (stronger than RSA, not NSA-influenced)
#   -a 100     → 100 KDF rounds (makes brute-force harder)
#   -C         → Adds a comment (email for identification)
#   -f         → Output file
#   -N         → Sets passphrase (avoid plaintext in prod scripts!)
echo "Generating Ed25519 key (most secure)..."
ssh-keygen -t ed25519 -a 100 -C "$EMAIL" -f ~/.ssh/id_ed25519 -N "$PASSPHRASE"

# 2. Generate RSA-4096 Key (For Legacy Compatibility)
# Flags:
#   -t rsa     → Use RSA (still widely supported)
#   -b 4096    → 4096-bit key (stronger than default 3072)
#   -o         → Use new OpenSSH format (not legacy PEM)
#   -a 100     → 100 KDF rounds
echo "Generating RSA-4096 key (for compatibility)..."
ssh-keygen -t rsa -b 4096 -o -a 100 -C "$EMAIL" -f ~/.ssh/id_rsa -N "$PASSPHRASE"

# --- Post-Generation Security Checks ---
echo "Verifying key fingerprints..."
ssh-keygen -l -f ~/.ssh/id_ed25519
ssh-keygen -l -f ~/.ssh/id_rsa
# Lock down key permissions

echo "Setting strict permissions..."
chmod 600 ~/.ssh/id_*
#    6 (Owner) → 4 (read) + 2 (write) = 6 → rw-
#    0 (Group) → No permissions → ---
#    0 (Others) → No permissions → ---

chmod 644 ~/.ssh/*.pub
#    6 (Owner) → rw-
#    4 (Group) → r-- (read-only)
#    4 (Others) → r-- (read-only)

chmod 700 ~/.ssh
#    7 (Owner) → 4 (read) + 2 (write) + 1 (execute) = 7 → rwx
#    0 (Group) → No permissions → ---
#    0 (Others) → No permissions → ---

# drwx------  2 user user 4096 Jun 10 10:00 .ssh/
# -rw-------  1 user user  505 Jun 10 10:00 id_ed25519
# -rw-r--r--  1 user user  100 Jun 10 10:00 id_ed25519.pub
# -rw-------  1 user user 3381 Jun 10 10:00 id_rsa
# -rw-r--r--  1 user user  750 Jun 10 10:00 id_rsa.pub


# --- Security Notes ---
cat <<EOF > ~/.ssh/security_notes.txt

=== Security Recommendations ===

1. **Passphrase Management**:
   - To change a passphrase later, run:
     ssh-keygen -p -f ~/.ssh/id_ed25519  # Ed25519
     ssh-keygen -p -f ~/.ssh/id_rsa      # RSA
   - Never use empty passphrases in production!

2. **Disable Weak Algorithms** (Edit /etc/ssh/sshd_config):
   # Preferred settings (reject NSA-influenced NIST curves):
   KexAlgorithms curve25519-sha256@libssh.org
   HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256
   Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
   MACs hmac-sha2-512-etm@openssh.com

3. **Key Usage**:
   - Use Ed25519 for modern systems.
   - Use RSA only if required (e.g., legacy servers).

4. **Backup & Permissions**:
   - Backup ~/.ssh/ securely.
   - Set strict permissions:
     chmod 600 ~/.ssh/id_* && chmod 700 ~/.ssh

EOF

chmod +x ~/.ssh/generate_ssh_keys.sh
~/./ssh/generate_ssh_keys.sh