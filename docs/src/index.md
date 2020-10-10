# EasyStream.jl
*An extensible framework for data stream in Julia.*

[![Build Status](https://img.shields.io/travis/com/ATISLabs/EasyStream.jl?style=flat-square)](https://travis-ci.com/ATISLabs/EasyStream.jl)
[![Coverage Status](https://img.shields.io/codecov/c/github/ATISLabs/EasyStream.jl/master?style=flat-square&token=13TrPsgakO)](https://coveralls.io/github/ATISLabs/EasyStream.jl)
[![Latest Documentation](https://img.shields.io/badge/docs-dev-blue.svg?style=flat-square)](https://atislabs.github.io/EasyStream.jl/dev/)
[![License File](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](https://github.com/ATISLabs/EasyStream.jl/blob/master/LICENSE)

## Overview

EasyStream.jl aims to create a simple interface to work with data stream, acting, for example, in Concept Drift related problems. In the next sections we discuss the basic elements of the framework.

## Installation

Get the latest stable release with Julia's package manager:

```julia
] add EasyStream
```

## Tutorials

Under construction.

## Quick example

Below is a quick preview of the high-level API:

```@example overview

using EasyStream
using SyntheticDatasets

conn_gen = EasyStream.GeneratorConnector(SyntheticDatasets.generate_blobs, 
						centers = [-1 1;-0.5 0.75], 
                                        	cluster_std = 0.225, 
                                        	center_box = (-1.5, 1.5));
```

## Project organization

The project is split into various packages:

| Package | Description |
|:-------:|:------------|
| [StreamDatasets.jl](https://github.com/ATISLabs/StreamDatasets.jl) | Package with stream datasets (under construction).|
| [SyntheticDatasets.jl](https://github.com/ATISLabs/SyntheticDatasets.jl) |Package with synthetics datasets.|
