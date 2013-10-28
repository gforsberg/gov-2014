/**
 * New Relic agent configuration.
 *
 * See lib/config.defaults.js in the agent distribution for a more complete
 * description of configuration variables and their potential values.
 */

require("./config")

exports.config = {
  /**
   * Array of application names.
   */
  app_name : ['GOV 2014'],
  /**
   * Your New Relic license key.
   */
  license_key : config.newrelic_Key,
  logging : {
    /**
     * Level at which to log. 'trace' is most useful to New Relic when diagnosing
     * issues with the agent, 'info' and higher will impose the least overhead on
     * production applications.
     */
    level : 'info'
  }
};
