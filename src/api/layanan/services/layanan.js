'use strict';

/**
 * layanan service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::layanan.layanan');
