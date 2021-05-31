using Images
using ProgressMeter
include("vector.jl")

# IMAGE
aspectratio = 16 / 9
imwidth = 800
imheight = trunc(Int64, imwidth / aspectratio)

# CAMERA
viewportheight = 2.0
viewportwidth = viewportheight * aspectratio
horizontal = Vec3(viewportwidth, 0.0, 0.0)
vertical = Vec3(0.0, viewportheight, 0.0)
focallenght = 1.0
origin = Vec3(0.0, 0.0, 0.0)
lowerleftcorner = origin - horizontal/2 - vertical/2 - Vec3(0.0, 0.0, focallenght)

# LIGHT FACTORS
factor = 1.0
Kdr = 0.3*factor
Kdg = 0.6*factor
Kdb = 0.1*factor
n = 5

println("Image size $imwidth x $imheight")

function backgroundcolor(dir)
    t = 0.5 * (dir[2] + 1.0)
    color1 = RGB(1.0, 1.0, 1.0)
    color2 = RGB(0.1, 0.1, 0.1)
    return (1-t)*color1 + t*color2
end

clamp(value::AbstractFloat, vmin=0.0, vmax=1.0) = min(max(value, vmin), vmax)

function clamp(color::RGB, vmin=0.0, vmax=1.0)
    res = clamp.([color.r, color.g, color.b], vmin, vmax)
    RGB(res...)
end

function raycolor(ray::Ray, sphere::Sphere, lightSource::LightSource)
    t = hit!(sphere, ray)

    if t > 0.0
        p = rayat(ray, t)
        normal = unitvector(p - sphere.center)

        L = unitvector(lightSource.lightPos - p)
        R = unitvector(reflect( p - lightSource.lightPos , normal))
        V = unitvector(origin - p)

        NL = dot(normal, L)
        KsRVn = sphere.ks*dot(R, V)^n

        r = (Kdr*NL + KsRVn)*sphere.color.r + lightSource.lightColor.r
        g = (Kdg*NL + KsRVn)*sphere.color.g + lightSource.lightColor.g
        b = (Kdb*NL + KsRVn)*sphere.color.b + lightSource.lightColor.b

        return RGB(r, g, b)
    end
    backgroundcolor(ray.direction)
end

function render(sphere::Sphere, lightSource::LightSource, samples_perpixel=100)
    image = RGB.(zeros(imheight, imwidth))
    @showprogress 1 "Computing..." for j = 1:imheight
        for i = 1:imwidth
            pixelcolor = RGB(0.0, 0.0, 0.0)
            for n = 1:samples_perpixel
                u = (i - 1 + rand()) / (imwidth - 1)
                v = 1.0 - (j - 1 + rand()) / (imheight - 1)
                dir = lowerleftcorner + u*horizontal + v*vertical - origin
                ray = Ray(origin, dir)
                pixelcolor += raycolor(ray, sphere, lightSource)
            end
            image[j, i] = clamp(pixelcolor / samples_perpixel)
        end
    end
    image
end


spherecolor = RGB(0.0, 1.0, 0.5)
s1 = Sphere(Vec3(0.0, 0.0, -1.0), 0.5, spherecolor, 0.0) # Lambertian
ls1 = LightSource(π/4, π/4, 1.2, RGB(0.0,0.0,0.0))
frame1 = render(s1, ls1, 50)
save("rendered/lambertiana.png", frame1)

spherecolor = RGB(0.0, 0.0, 1.0)
s2 = Sphere(Vec3(0.0, 0.0, -1.0), 0.5, spherecolor, 0.8) # Phong1
ls2 = LightSource(3*π/4, π/4, 3.0, RGB(0.0,0.0,0.0))
frame2 = render(s2, ls2, 50)
save("rendered/phong1.png", frame2)

spherecolor = RGB(0.34, 0.0, 0.66)
s3 = Sphere(Vec3(0.0, 0.0, -1.0), 0.5, spherecolor, 0.4) # Phong2
ls3 = LightSource(7*π/4, π/2, 0.8, RGB(0.0,0.0,0.0))
frame3 = render(s3, ls3, 50)
save("rendered/phong2.png", frame3)