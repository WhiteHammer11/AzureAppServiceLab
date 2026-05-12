using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace AzureAppServiceLab.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DemoController : ControllerBase
    {

        [HttpGet("Hello")]
        public IActionResult Hello()
        {
            return Ok("Hello world from github actions");
        }
    }
}
