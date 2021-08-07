const AWS = require("aws-sdk");
const cloudfront = new AWS.CloudFront();

exports.handler = async (event) => {
  var s3_bucket_name;

  console.log(JSON.stringify(event, null, 2));

  try {
    s3_bucket_name = event.Records[0].s3.bucket.name;
  } catch (error) {
    console.log("Error reading the s3 bucket from the AWS S3 Event");
    console.log(error);
  }

  try {
  } catch (error) {
    console.log("Error reading the site mappings");
    console.log(error);
  }

  const cloudfrontDistributionId = Object.keys(process.env).find(
    (k) => process.env[k] === s3_bucket_name
  );

  if (!cloudfrontDistributionId) {
    return {
      statusCode: 404,
      body: "Error no mapping for s3",
    };
  }

  console.log("Invalidating:", cloudfrontDistributionId);

  var params = {
    DistributionId: cloudfrontDistributionId,
    InvalidationBatch: {
      CallerReference: Date.now().toString(),
      Paths: {
        Quantity: 1,
        Items: ["/*"],
      },
    },
  };

  try {
    const invalidation = await cloudfront.createInvalidation(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify(invalidation),
    };
  } catch (e) {
    console.log("Failed", e);
    return {
      statusCode: 404,
      body: JSON.stringify(e),
    };
  }
};
