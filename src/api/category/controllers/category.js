"use strict";

/**
 * category controller
 */

const { createCoreController } = require("@strapi/strapi").factories;

module.exports = createCoreController(
  "api::category.category",
  ({ strapi }) => ({
    async find(ctx) {
      const { populateBlogs } = ctx.query;
      const { populateAllBlogs } = ctx.query;

      const categories = await strapi.db
        .query("api::category.category")
        .findMany();

      if (populateBlogs) {
        for (const category of categories) {
          category.blogs = await strapi.db.query("api::blog.blog").findMany({
            where: { category: category.id },
            populate: true,
            limit: 3,
          });
        }
      }

      if (populateAllBlogs) {
        for (const category of categories) {
          category.blogs = await strapi.db.query("api::blog.blog").findMany({
            where: { category: category.id },
            populate: true,
          });
        }
      }

      const sanitiedCategories = await this.sanitizeOutput(categories, ctx);

      return this.transformResponse(sanitiedCategories);
    },
  })
);
