exports.handler = async (event, context) => {
  console.log(1);
  console.log(JSON.stringify(event));
  console.log(2);
  console.log(JSON.stringify(context));
  console.log(3);

  /*
   * Generate HTTP redirect response with 302 status code and Location header.
   */
  const response = {
    status: "302",
    statusDescription: "Found",
    headers: {
      location: [
        {
          key: "Location",
          value: "http://docs.aws.amazon.com/lambda/latest/dg/lambda-edge.html",
        },
      ],
    },
  };
  return response;
};
